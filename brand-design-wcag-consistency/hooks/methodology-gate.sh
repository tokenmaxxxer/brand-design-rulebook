#!/usr/bin/env bash
. "${CLAUDE_PLUGIN_ROOT_CORE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd -P)}/hooks/lib/gate-lib.sh" || { echo "methodology-gate.sh: cannot source gate-lib.sh" >&2; exit 2; }
gate_trap_fail_closed
# PreToolUse gate (Write|Edit|MultiEdit) — brand-design-role-specific, on top
# of (never instead of) the core canon record-fields-gate.sh's generic §20
# fields. Modeled on pricing-rulebook's pricing/hooks/methodology-gate.sh
# (cite: docs/issue-10/reports/brand-design/scout-brief.md must-bes 2-4, 7).
# Migrated to the gate-house standard (core issue #72) per issue-13's
# remediation, mirroring wcag-em-gate's precedent structure.
#
# Owns exactly one methodology concern (cite: docs/issue-10/proposals/
# 2026-07-31-brand-design-directive-hardening.md, "Plugin set overview"):
# consistency check vs. existing guide + WCAG contrast gate, from the
# adopted charter (docs/issue-1/proposals/
# 2026-07-31-brand-design-methodology-charter.md, component 3).
#
# Targets: docs/issue-<n>/reports/brand-design.md (phase-2 record) only.
#
# Kill switch: export BRAND_DESIGN_WCAG_CONSISTENCY_GATE_OFF=1 (any other
# value leaves it active, per gate_kill_switch_active's fixed on-spelling
# set — 1/true/yes/on).
set -uo pipefail

role="${CLAUDE_ROLE:-brand-design}"
deny() { echo "${role}: refused — $1" >&2; exit 2; }

gate_kill_switch_active "${BRAND_DESIGN_WCAG_CONSISTENCY_GATE_OFF:-}" || { trap - EXIT; exit 0; }

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

    path = ti.get("file_path")
    if not isinstance(path, str) or not path:
        sys.exit(0)

    rel = gate_lib.gate_normalize_path(root, path)
    if rel is None:
        sys.exit(0)
    if not RECORD_RE.match(rel):
        sys.exit(0)

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
            "Edit/MultiEdit whose old_string(s) match, so the consistency-check/WCAG fields "
            "can be checked." % (rel, tool)
        )

    # --- section/adjacency-scoped semantic checks ---
    #
    # A "pairing paragraph" is the span of lines starting at a label-shaped
    # line (a markdown heading `#{1,6} <label>` or a `<label>:` field line,
    # matched case-insensitively) through the next blank line or the next
    # label-shaped line, whichever comes first. A ratio number and a
    # pass/fail verdict must co-occur within the SAME such paragraph — a
    # ratio in one section can no longer satisfy a verdict claimed in an
    # unrelated section (issue-13 fix).

    lines = new_text.splitlines()

    LABEL_WORDS = ("consistency check", "text/background", "contrast", "pairing")
    # The field-style alternative's label text (before the colon) must not
    # contain a digit — this keeps body text like "contrast ratio 4.6:1,
    # pass..." (whose first colon falls inside the ratio number itself)
    # from being mistaken for a `label:` field line and fracturing a
    # pairing paragraph mid-sentence (issue-13 fix).
    LABEL_LINE_RE = re.compile(
        r'^\s*(?:#{1,6}\s*(?P<h>.+?)\s*|(?P<f>[^:\n\d]+):\s*.*)$'
    )

    def is_label_line(line):
        """Return True if `line` is heading-shaped or `label:`-shaped and
        its label text contains one of the pairing/consistency label words
        (case-insensitively)."""
        m = LABEL_LINE_RE.match(line)
        if not m:
            return False
        text = m.group("h") or m.group("f") or ""
        low = text.strip().lower()
        return any(w in low for w in LABEL_WORDS)

    def paragraph_span(start_idx):
        """From a label line at start_idx, return the paragraph text
        (start_idx through the next blank line or next label-shaped line,
        exclusive)."""
        j = start_idx
        n = len(lines)
        end = n
        # include the label line itself, then scan forward
        k = start_idx + 1
        # For a markdown heading (`## label`), the conventional blank line
        # separating the heading from its body must not itself terminate
        # the paragraph — skip past blank lines immediately following a
        # heading before applying the blank-line/next-label-line cutoff
        # (issue-13 fix; a `label:` field line has no such convention and
        # is left alone).
        if lines[start_idx].lstrip().startswith("#"):
            while k < n and lines[k].strip() == "":
                k += 1
        while k < n:
            if lines[k].strip() == "":
                end = k
                break
            if is_label_line(lines[k]):
                end = k
                break
            k += 1
        else:
            end = n
        return "\n".join(lines[start_idx:end])

    RATIO_RE = re.compile(r'\d+(\.\d+)?\s*:\s*1')
    VERDICT_RE = re.compile(r'(?i)\bpass\b|\bfail\b|\baa\b|\baaa\b')
    EARLY_EXIT_RE = re.compile(
        r'(?i)no new text/background pairing|no new pairing|no color pairing introduced'
    )

    paragraphs = []
    for i, line in enumerate(lines):
        if is_label_line(line):
            paragraphs.append(paragraph_span(i))

    if not paragraphs:
        # No labeled pairing/consistency-check section at all in the
        # document. Fall back to whole-document early-exit detection so a
        # simple one-line record ("no new pairing introduced.") still
        # passes without requiring a heading.
        if EARLY_EXIT_RE.search(new_text):
            sys.exit(0)
        # Also allow documents that mention none of the pairing label words
        # anywhere — nothing to check.
        low_whole = new_text.lower()
        if not any(w in low_whole for w in LABEL_WORDS):
            sys.exit(0)
        deny(
            "brand-design record mentions a pairing/consistency-check concept but has no "
            "labeled section (heading or `label:` line) to scope the check against, and no "
            "explicit early-exit statement (e.g. 'no new text/background pairing introduced'). "
            "Per docs/issue-1/proposals/2026-07-31-brand-design-methodology-charter.md, name a "
            "labeled paragraph or state the early-exit explicitly."
        )

    missing = []
    any_pairing_paragraph_ok = False
    any_pairing_paragraph_seen = False

    for para in paragraphs:
        if EARLY_EXIT_RE.search(para):
            any_pairing_paragraph_ok = True
            continue
        any_pairing_paragraph_seen = True
        ratio_present = bool(RATIO_RE.search(para))
        verdict_present = bool(VERDICT_RE.search(para))
        if ratio_present and verdict_present:
            any_pairing_paragraph_ok = True
        else:
            missing.append("wcag-contrast-ratio-and-verdict")

    if any_pairing_paragraph_seen and not any_pairing_paragraph_ok:
        missing.append("consistency-check-verdict")

    if not any_pairing_paragraph_seen and not any_pairing_paragraph_ok:
        missing.append("consistency-check-early-exit")

    if missing:
        deny(
            "brand-design record is missing required element(s): %s. Per "
            "docs/issue-1/proposals/2026-07-31-brand-design-methodology-charter.md, "
            "every brand-design phase-2 record with a new text/background color "
            "pairing must carry a named per-item pass/fail consistency check and a "
            "WCAG ratio number (e.g. 4.6:1) with an explicit pass/fail against "
            "4.5:1 (normal) or 3:1 (large), co-located within that pairing's own "
            "labeled section; a record with no new pairing must say so explicitly "
            "(e.g. 'no new text/background pairing introduced')." % ", ".join(dict.fromkeys(missing))
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
