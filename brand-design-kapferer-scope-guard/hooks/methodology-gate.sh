#!/usr/bin/env bash
. "${CLAUDE_PLUGIN_ROOT_CORE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd -P)}/hooks/lib/gate-lib.sh" || { echo "methodology-gate.sh: cannot source gate-lib.sh" >&2; exit 2; }
gate_trap_fail_closed
# PreToolUse gate (Write|Edit|MultiEdit) — brand-design-role-specific, on top
# of (never instead of) the core canon record-fields-gate.sh's generic §20
# fields. Modeled on pricing-rulebook's pricing/hooks/methodology-gate.sh
# (cite: docs/issue-10/reports/brand-design/scout-brief.md must-bes 2-4, 7).
#
# Migrated to the gate-house standard (core issue #72) per issue-13's B-
# grade audit: hand-rolled trap/kill-switch/JSON-parse/path-resolve/
# Write-Edit-MultiEdit-reconstruction machinery replaced by gate-lib.sh /
# gate-lib.py, and the flat substring/`in low` membership semantic checks
# upgraded to section/adjacency-scoped label+paragraph checks.
#
# Owns exactly one methodology concern, phase-aware (cite: docs/issue-10/
# proposals/2026-07-31-brand-design-directive-hardening.md, "Plugin set
# overview"): Kapferer Physique-facet scope boundary (phase-1) +
# prohibitions acknowledgement (phase-2), from the adopted charter
# (docs/issue-1/proposals/2026-07-31-brand-design-methodology-charter.md,
# "Justification tied to YOU_DECIDE").
#
# Targets: BOTH docs/issue-<n>/proposals/*brand-design*.md (phase-1) and
# docs/issue-<n>/reports/brand-design.md (phase-2), branching mode by
# which write-surface matched — the only one of the four brand-design-*
# plugins active on both surfaces.
#
# Kill switch: export BRAND_DESIGN_KAPFERER_SCOPE_GUARD_GATE_OFF=1 (any
# other value leaves it active, per gate_kill_switch_active's fixed
# on-spelling set — 1/true/yes/on).
set -uo pipefail

role="${CLAUDE_ROLE:-brand-design}"
deny() { echo "${role}: refused — $1" >&2; exit 2; }

gate_kill_switch_active "${BRAND_DESIGN_KAPFERER_SCOPE_GUARD_GATE_OFF:-}" || { trap - EXIT; exit 0; }

command -v python3 >/dev/null 2>&1 || deny "methodology-gate.sh requires python3, which is not on PATH; denying rather than guessing."

payload="$(cat 2>/dev/null || true)"

_plausible() { [ -n "$1" ] && [ -d "$1" ] && { [ -e "$1/.git" ] || [ -f "$1/docs/specs/role-handoff-contract.md" ]; }; }

root=""
if [ -n "${CLAUDE_PROJECT_DIR:-}" ] && _plausible "$CLAUDE_PROJECT_DIR"; then
  root="$(cd "$CLAUDE_PROJECT_DIR" 2>/dev/null && pwd -P)"
fi
[ -z "$root" ] && root="$(git -C "$(pwd -P)" rev-parse --show-toplevel 2>/dev/null || true)"
[ -z "$root" ] && deny "no project root could be determined; failing closed (methodology check cannot run)."

PG_PAYLOAD="$payload" PG_ROOT="$root" GATE_LIB_PY="$GATE_LIB_PY" \
python3 <<'PY'
import sys as _fc_sys  # fail-closed-on-internal-error
try:
    import importlib.util, json, os, re, sys

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
    PROPOSAL_RE = re.compile(r'^docs/issue-[0-9]+/proposals/.*brand-design.*\.md$', re.I)
    RECORD_RE = re.compile(r'^docs/issue-[0-9]+/reports/brand-design\.md$')

    path = ti.get("file_path")
    if not isinstance(path, str) or not path:
        sys.exit(0)

    rel = gate_lib.gate_normalize_path(root, path)
    if rel is None:
        sys.exit(0)  # resolves outside the project root — not this gate's business

    is_proposal = bool(PROPOSAL_RE.match(rel))
    is_record = bool(RECORD_RE.match(rel))
    if not (is_proposal or is_record):
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
            "Edit/MultiEdit whose old_string matches, so the scope/prohibitions "
            "acknowledgement can be checked." % (rel, tool)
        )

    # --- section/adjacency-scoped field check helpers -----------------
    # A field is "present" only if its label appears as a heading-shaped
    # (`^\s*#{1,6}\s*<label>`) or label-shaped (`^\s*<label>\s*:`) line,
    # checked line-by-line (case-insensitive) against new_text — not a
    # flat substring/`in low` membership check over the whole flattened
    # doc. A claim/value is "in" that field only if it occurs within the
    # label's own paragraph: the span from the label line to the next
    # blank line or next label-shaped line (whichever comes first).
    lines = new_text.splitlines()

    def _label_pattern(label):
        esc = re.escape(label)
        return re.compile(r'^\s*(?:#{1,6}\s*%s\b|%s\s*:)' % (esc, esc), re.I)

    LABEL_LINE = re.compile(r'^\s*(?:#{1,6}\s*\S|[A-Za-z][A-Za-z0-9 _/-]{0,40}:\s)')

    def label_paragraphs(label):
        """Yield the paragraph text (joined lines) for each occurrence of
        `label` as a heading/label-shaped line."""
        pat = _label_pattern(label)
        n = len(lines)
        for i, line in enumerate(lines):
            if not pat.match(line):
                continue
            j = i + 1
            while j < n and lines[j].strip() != "" and not (j != i + 1 and LABEL_LINE.match(lines[j])):
                j += 1
            yield "\n".join(lines[i:j])

    def paragraph_has_any(label, *needles):
        for para in label_paragraphs(label):
            low_para = para.lower()
            if any(nd in low_para for nd in needles):
                return True
        return False

    def any_paragraph_has(labels, *needles):
        return any(paragraph_has_any(lbl, *needles) for lbl in labels)

    def doc_has_early_exit(*phrases):
        # "not applicable: <reason>" / "no new pairing introduced" style
        # early-exit allowance is checked at paragraph level too, but since
        # it isn't tied to one specific field label we scan any label-shaped
        # or heading-shaped paragraph in the doc, plus bare top-level prose
        # paragraphs (span between blank lines).
        n = len(lines)
        i = 0
        while i < n:
            if lines[i].strip() == "":
                i += 1
                continue
            j = i
            while j < n and lines[j].strip() != "":
                j += 1
            para_low = "\n".join(lines[i:j]).lower()
            if any(p in para_low for p in phrases):
                return True
            i = j
        return False

    missing = []

    if is_proposal:
        scope_ack = any_paragraph_has(
            ("scope", "kapferer scope", "physique facet", "physique-facet scope"),
            "physique", "kapferer", "visual facet",
        )
        early_exit = doc_has_early_exit("no scoping question", "scope boundary not applicable")
        if not (scope_ack or early_exit):
            missing.append("kapferer-scope-boundary-acknowledgement")
    else:  # is_record — phase-2
        prohibitions_ack = any_paragraph_has(
            ("prohibitions", "prohibition"),
            "undocumented color", "undocumented font", "wcag number omitted",
            "wcag omitted", "token-systemization",
        ) and any_paragraph_has(
            ("prohibitions", "prohibition"),
            "not triggered", "avoided by",
        )
        early_exit = doc_has_early_exit("no new pairing introduced")
        if not (prohibitions_ack or early_exit):
            missing.append("prohibitions-acknowledgement")

    if missing:
        deny(
            "brand-design write is missing required element(s): %s. Per "
            "docs/issue-1/proposals/2026-07-31-brand-design-methodology-charter.md, "
            "a phase-1 proposal must name the Physique-facet-only scope boundary (or "
            "an explicit early-exit note that no scoping question arose), and a "
            "phase-2 record must name each of the charter's prohibitions as either "
            "'not triggered' or how it was avoided, within a labeled Prohibitions "
            "section/paragraph." % ", ".join(missing)
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
