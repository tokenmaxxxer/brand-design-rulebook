#!/usr/bin/env bash
. "${CLAUDE_PLUGIN_ROOT_CORE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd -P)}/hooks/lib/gate-lib.sh" || { echo "methodology-gate.sh: cannot source gate-lib.sh" >&2; exit 2; }
gate_trap_fail_closed
# PreToolUse gate (Write|Edit|MultiEdit) — brand-design-role-specific, on top
# of (never instead of) the core canon record-fields-gate.sh's generic §20
# fields. Modeled on pricing-rulebook's pricing/hooks/methodology-gate.sh
# (cite: docs/issue-10/reports/brand-design/scout-brief.md must-bes 2-4, 7).
#
# Migrated to the gate-house standard (core issue #72) per issue-13's B-
# grade audit remediation, mirroring wcag-em-gate/hooks/methodology-gate.sh
# (accessibility-rulebook issue-10) as the live precedent.
#
# Owns exactly one methodology concern (cite: docs/issue-10/proposals/
# 2026-07-31-brand-design-directive-hardening.md, "Plugin set overview"):
# design-system source paths + the Atomic-Design HAND_OFF -> ux-engineering
# boundary discipline, from the adopted charter (docs/issue-1/proposals/
# 2026-07-31-brand-design-methodology-charter.md, component 4).
#
# Targets: docs/issue-<n>/reports/brand-design.md (phase-2 record) only.
#
# Kill switch: export BRAND_DESIGN_SYSTEM_HANDOFF_GATE_OFF=1 (any other
# value leaves it active, per gate_kill_switch_active's fixed on-spelling
# set — 1/true/yes/on).
set -uo pipefail

role="${CLAUDE_ROLE:-brand-design}"
deny() { echo "${role}: refused — $1" >&2; exit 2; }

gate_kill_switch_active "${BRAND_DESIGN_SYSTEM_HANDOFF_GATE_OFF:-}" || { trap - EXIT; exit 0; }

command -v python3 >/dev/null 2>&1 || deny "methodology-gate.sh requires python3, which is not on PATH; denying rather than guessing."

payload="$(cat 2>/dev/null || true)"
[ -n "$payload" ] || deny "methodology-gate: empty tool-use payload on stdin; cannot evaluate the methodology gate."

_target="$(printf '%s' "$payload" | python3 -c '
import json,sys
try: e=json.loads(sys.stdin.read())
except Exception: sys.exit(0)
ti=e.get("tool_input") if isinstance(e,dict) else None
if isinstance(ti,dict):
    for k in ("file_path","notebook_path"):
        v=ti.get(k)
        if isinstance(v,str) and v: print(v); break
' 2>/dev/null || true)"

_plausible() { [ -n "$1" ] && [ -d "$1" ] && { [ -e "$1/.git" ] || [ -f "$1/docs/specs/role-handoff-contract.md" ]; }; }
_under() {
  [ -z "$2" ] && return 0
  python3 -c '
import os,posixpath,sys
r,t=sys.argv[1],sys.argv[2]
try: rr=posixpath.normpath(os.path.realpath(r).replace("\\","/"))
except Exception: sys.exit(1)
n=t.replace("\\","/"); a=n if posixpath.isabs(n) else posixpath.join(rr,n)
a=posixpath.normpath(a); real=posixpath.normpath(os.path.realpath(a).replace("\\","/"))
sys.exit(0 if (real==rr or real.startswith(rr+"/")) else 1)
' "$1" "$2"
}

root=""
if [ -n "${CLAUDE_PROJECT_DIR:-}" ] && _plausible "$CLAUDE_PROJECT_DIR" && _under "$CLAUDE_PROJECT_DIR" "$_target"; then
  root="$(cd "$CLAUDE_PROJECT_DIR" 2>/dev/null && pwd -P)"
fi
if [ -z "$root" ]; then
  d="$_target"; [ -n "$d" ] || d="$(pwd -P)"; [ -d "$d" ] || d="$(dirname "$d")"
  root="$(git -C "$d" rev-parse --show-toplevel 2>/dev/null || true)"
fi
[ -z "$root" ] && root="$(git -C "$(pwd -P)" rev-parse --show-toplevel 2>/dev/null || true)"
[ -z "$root" ] && deny "no project root could be determined; failing closed (methodology check cannot run)."

PG_PAYLOAD="$payload" PG_ROOT="$root" GATE_LIB_PY="$GATE_LIB_PY" \
python3 <<'PY'
import sys as _fc_sys  # fail-closed-on-internal-error
try:
    import importlib.util, json, os, posixpath, re, sys

    def deny(m):
        sys.stderr.write("brand-design: refused — %s\n" % m); sys.exit(2)

    _spec = importlib.util.spec_from_file_location("gate_lib", os.environ["GATE_LIB_PY"])
    gate_lib = importlib.util.module_from_spec(_spec)
    _spec.loader.exec_module(gate_lib)

    raw = os.environ.get("PG_PAYLOAD", "")
    ev = gate_lib.gate_parse_json_or_deny(raw, deny)

    tool = ev.get("tool_name")
    if tool not in ("Write", "Edit", "MultiEdit"):
        sys.exit(0)

    ti = ev.get("tool_input")
    if not isinstance(ti, dict):
        deny("tool_input is missing or not a JSON object; the gate cannot judge a write it cannot parse (methodology).")

    root = os.path.realpath(os.environ["PG_ROOT"]).replace("\\", "/")
    RECORD_RE = re.compile(r'^docs/issue-[0-9]+/reports/brand-design\.md$')
    PROPOSAL_RE = re.compile(r'^docs/issue-[0-9]+/proposals/.*brand-design.*\.md$', re.I)

    path = ti.get("file_path")
    if not isinstance(path, str) or not path:
        sys.exit(0)

    rel = gate_lib.gate_normalize_path(root, path)
    if rel is None:
        sys.exit(0)  # resolves outside the project root — not this gate's business
    if not RECORD_RE.match(rel):
        sys.exit(0)  # not this role's own record — not this gate's business

    abs_path = root + "/" + rel if rel else root
    current = None
    if os.path.isfile(abs_path):
        try:
            with open(abs_path, encoding="utf-8-sig") as fh:
                current = fh.read(1 << 20)
        except OSError:
            deny("%s exists but cannot be read; failing closed on methodology." % rel)

    new_text, ok = gate_lib.gate_reconstruct_write(tool, ti, current)
    if not ok:
        deny(
            "this write targets %s but the gate cannot determine the resulting content "
            "from the tool input (tool=%r). Write the full document with Write, or use an "
            "Edit/MultiEdit whose old_string matches, so the design-system source paths "
            "can be checked." % (rel, tool)
        )

    # --- design-system source paths: section/adjacency-scoped -----------
    # The label "design-system source paths" (or "design system source
    # paths") must appear as a heading-shaped (`^\s*#{1,6}\s*<label>`) or
    # label-shaped (`^\s*<label>\s*:`) line, case-insensitive, checked
    # line-by-line — not a flat substring/lowercased-and-flattened
    # membership test. The concrete literal path token, or an explicit
    # "not applicable"/"no new pairing introduced" allowance, must occur
    # within that label's own paragraph (the label line through the next
    # blank line or next label/heading line).
    LABEL_RE = re.compile(
        r'^\s*(?:#{1,6}\s*)?design[- ]system source paths\s*:?\s*(.*)$',
        re.I,
    )
    ANY_HEADING_OR_LABEL_RE = re.compile(r'^\s*(?:#{1,6}\s+\S|[A-Za-z][A-Za-z0-9_ -]*:\s*)')
    NOT_APPLICABLE_RE = re.compile(r'(?i)\bnot applicable\b|\bno new pairing introduced\b')
    # A literal repo path token: contains "/", not this repo's own
    # write-surface patterns (proposal/record path regexes), not a URL.
    PATH_TOKEN_RE = re.compile(
        r'`?((?:docs|src|assets|core|brand-design(?:-[\w-]+)?)/[\w./-]*\.[\w]+|`[\w][\w./-]*/[\w][\w./-]*\.[\w]+`)`?'
    )

    def is_own_surface_or_url(cand):
        if PROPOSAL_RE.match(cand) or RECORD_RE.match(cand):
            return True
        if cand.startswith("http://") or cand.startswith("https://"):
            return True
        return False

    lines = new_text.splitlines()
    label_idx = None
    trailing = ""
    for i, line in enumerate(lines):
        m = LABEL_RE.match(line)
        if m:
            label_idx = i
            trailing = m.group(1) or ""
            break

    if label_idx is None:
        deny(
            "brand-design record is missing required element: design-system-source-paths. "
            "Per docs/issue-1/proposals/2026-07-31-brand-design-methodology-charter.md, "
            "every brand-design phase-2 record must name literal repo paths for the "
            "design-system sources it touched or hands off, not a description of what "
            "ux-engineering 'should' build. The label must appear on its own heading- or "
            "label-shaped line (e.g. '## design-system source paths' or "
            "'design-system source paths: ...')."
        )

    # paragraph span: label line through next blank line or next
    # heading/label-shaped line (exclusive), starting from any trailing
    # content on the label line itself.
    para_lines = [trailing]
    j = label_idx + 1
    while j < len(lines):
        line = lines[j]
        if line.strip() == "":
            break
        if ANY_HEADING_OR_LABEL_RE.match(line) and not line.strip().lower().startswith(("http://", "https://")):
            break
        para_lines.append(line)
        j += 1
    paragraph = "\n".join(para_lines)

    if NOT_APPLICABLE_RE.search(paragraph):
        sys.exit(0)

    found_path = False
    for m in PATH_TOKEN_RE.finditer(paragraph):
        cand = m.group(1)
        if is_own_surface_or_url(cand):
            continue
        found_path = True
        break

    if not found_path:
        deny(
            "brand-design record has a design-system-source-paths label but no literal repo "
            "path (or an explicit 'not applicable' / 'no new pairing introduced' allowance) "
            "within that label's own paragraph. Per docs/issue-1/proposals/"
            "2026-07-31-brand-design-methodology-charter.md, name literal repo paths for the "
            "design-system sources touched or handed off, in the same paragraph as the label."
        )

    sys.exit(0)
except SystemExit:
    raise
except Exception as _fc_e:  # fail-closed-on-internal-error
    _fc_sys.stderr.write("methodology-gate.sh: fail-closed: internal error: %r\n" % (_fc_e,))
    _fc_sys.exit(2)
PY
_fc_rc=$?  # fail-closed-on-internal-error
if [ "$_fc_rc" -ne 0 ] && [ "$_fc_rc" -ne 2 ]; then
  echo "brand-design: refused — fail-closed: internal error (judge exited $_fc_rc)" >&2
  exit 2
fi
exit "$_fc_rc"
