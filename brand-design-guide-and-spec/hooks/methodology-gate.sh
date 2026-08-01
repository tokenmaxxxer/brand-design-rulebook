#!/usr/bin/env bash
. "${CLAUDE_PLUGIN_ROOT_CORE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd -P)}/hooks/lib/gate-lib.sh"
gate_trap_fail_closed
# ^ fail-closed trap-at-top, from gate-lib.sh (issue-72): any abnormal
#   termination (failed source, set -u abort, unbound var, etc.) before the
#   verdict logic runs is forced to exit 2 (DENY), since a PreToolUse hook
#   treats any non-2 exit as NON-BLOCKING (fail-OPEN). Installed as the
#   FIRST executable statement, above set -uo pipefail.
#
# PreToolUse gate (Write|Edit|MultiEdit) — brand-design-role-specific, on top
# of (never instead of) the core canon record-fields-gate.sh's generic §20
# fields. Modeled on pricing-rulebook's pricing/hooks/methodology-gate.sh
# (cite: docs/issue-10/reports/brand-design/scout-brief.md must-bes 2-4, 7).
#
# Owns exactly one methodology concern (cite: docs/issue-10/proposals/
# 2026-07-31-brand-design-directive-hardening.md, "Plugin set overview"):
# brand guide entry + asset spec presence/cross-reference, from the
# adopted charter (docs/issue-1/proposals/
# 2026-07-31-brand-design-methodology-charter.md).
#
# Targets: docs/issue-<n>/reports/brand-design.md (phase-2 record) only.
# Any write outside that surface, including phase-1 proposals, exits 0
# immediately (not this plugin's business — see
# brand-design-kapferer-scope-guard for phase-1).
#
# Migrated to the gate-house standard (core issue #72) per
# docs/handbooks/gate-house-standard.md — see wcag-em-gate/hooks/
# methodology-gate.sh for a precedent migration.
#
# Kill switch: export BRAND_DESIGN_GUIDE_AND_SPEC_GATE_OFF=1 (any other
# value leaves it active, per gate_kill_switch_active's fixed on-spelling
# set — 1/true/yes/on).
set -uo pipefail

role="${CLAUDE_ROLE:-brand-design}"
deny() { echo "${role}: refused — $1" >&2; exit 2; }

gate_kill_switch_active "${BRAND_DESIGN_GUIDE_AND_SPEC_GATE_OFF:-}" || { trap - EXIT; exit 0; }

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
    ti = ev.get("tool_input")

    path = None
    if tool in ("Write", "Edit", "MultiEdit"):
        if not isinstance(ti, dict):
            deny("tool_input is missing or not a JSON object; the gate cannot judge a write it cannot parse (methodology).")
        p = ti.get("file_path")
        if isinstance(p, str) and p:
            path = p
    if path is None:
        sys.exit(0)

    root = os.path.realpath(os.environ["PG_ROOT"]).replace("\\", "/")
    RECORD_RE = re.compile(r'^docs/issue-[0-9]+/reports/brand-design\.md$')

    rel = gate_lib.gate_normalize_path(root, path)
    if rel is None:
        sys.exit(0)  # resolves outside the project root — not this gate's business
    if not RECORD_RE.match(rel):
        sys.exit(0)  # not this plugin's write surface (proposal writes are kapferer-scope-guard's business)

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
            "Edit/MultiEdit whose old_string matches, so the brand-guide-entry/asset-spec "
            "fields can be checked." % (rel, tool)
        )

    HEX_RE = re.compile(r'#[0-9a-f]{3,8}\b|rgba?\s*\(', re.IGNORECASE)
    PATH_OR_FORMAT_RE = re.compile(r'\.(svg|png|jpg|jpeg|webp|otf|ttf|woff2?)\b', re.IGNORECASE)

    GUIDE_LABELS = [
        "logo usage", "typography", "voice/tone", "voice와 tone", "imagery style",
        "do's/don't", "do's and don't", "do/don't",
    ]
    ASSET_LABEL = "asset spec"
    NOT_APPLICABLE_LABEL = "not applicable"
    NOT_APPLICABLE_LABEL_KO = "해당 없음"

    lines = new_text.splitlines()
    n_lines = len(lines)

    def _label_pattern(label):
        esc = re.escape(label)
        # heading-shaped: ^\s*#{1,6}\s*<label>  OR label-shaped: ^\s*<label>\s*:
        return re.compile(r'(?i)^\s*(?:#{1,6}\s*%s\b|%s\s*:)' % (esc, esc))

    def find_label_lines(label):
        pat = _label_pattern(label)
        return [i for i, ln in enumerate(lines) if pat.match(ln)]

    # any label-shaped line at all (used to know where a paragraph ends —
    # the next label line of ANY tracked label also ends a paragraph)
    ALL_LABELS = GUIDE_LABELS + [ASSET_LABEL, NOT_APPLICABLE_LABEL, NOT_APPLICABLE_LABEL_KO]
    ANY_LABEL_PAT = re.compile(
        r'(?i)^\s*(?:#{1,6}\s*(?:%s)\b|(?:%s)\s*:)' % (
            "|".join(re.escape(l) for l in ALL_LABELS),
            "|".join(re.escape(l) for l in ALL_LABELS),
        )
    )

    def paragraph_span(start_idx):
        """Return (start_idx, end_idx_exclusive) for the paragraph beginning
        at start_idx: up to the next blank line or next label-shaped line
        (excluding start_idx itself)."""
        j = start_idx + 1
        while j < n_lines:
            if lines[j].strip() == "":
                break
            if ANY_LABEL_PAT.match(lines[j]):
                break
            j += 1
        return start_idx, j

    def paragraph_text(start_idx):
        s, e = paragraph_span(start_idx)
        return "\n".join(lines[s:e])

    def label_present(label):
        return len(find_label_lines(label)) > 0

    def label_paragraphs(label):
        return [paragraph_text(i) for i in find_label_lines(label)]

    missing = []

    # 1. Brand guide entry present — at least one concrete sub-field with its
    #    label present as its own heading/label-shaped line, or an explicit
    #    "not applicable: <reason>" early exit (paragraph-level).
    guide_present = any(label_present(lbl) for lbl in GUIDE_LABELS)
    not_applicable = label_present(NOT_APPLICABLE_LABEL) or label_present(NOT_APPLICABLE_LABEL_KO)

    def not_applicable_has_reason():
        for lbl in (NOT_APPLICABLE_LABEL, NOT_APPLICABLE_LABEL_KO):
            for para in label_paragraphs(lbl):
                # strip the label line itself to check for a reason after ':'
                m = re.search(r'(?i)(?:%s)\s*:\s*(\S.*)' % re.escape(lbl), para)
                if m and m.group(1).strip():
                    return True
        return False

    not_applicable_ok = not_applicable and not_applicable_has_reason()

    if not (guide_present or not_applicable_ok):
        missing.append("brand-guide-entry")

    # 2. Asset spec present — the "asset spec" label's own paragraph must
    #    carry a concrete applied value: a hex/rgb color, or a file-format
    #    token (bare path-shaped fallback removed — a real asset path is
    #    provable only by file-extension match or a color value).
    def asset_spec_ok():
        for i in find_label_lines(ASSET_LABEL):
            para = paragraph_text(i)
            if HEX_RE.search(para) or PATH_OR_FORMAT_RE.search(para):
                return True
        return False

    asset_spec_present = asset_spec_ok()
    if not (asset_spec_present or not_applicable_ok):
        missing.append("asset-spec")

    if missing:
        deny(
            "brand-design record is missing required element(s): %s. Per "
            "docs/issue-1/proposals/2026-07-31-brand-design-methodology-charter.md, "
            "every brand-design phase-2 record must carry a brand guide entry "
            "(concrete per-sub-field value, or an explicit 'not applicable: <reason>') "
            "and an asset spec (the literal applied value, distinct from the guide "
            "entry's rule statement), each with its own label on a heading- or "
            "label-shaped line and the concrete value within that same paragraph." % ", ".join(missing)
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
