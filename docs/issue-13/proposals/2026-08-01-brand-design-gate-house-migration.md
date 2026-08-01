# Proposal: brand-design gate-house A+ remediation (issue-13)

Phase-1 design only. No code changes in this PR — phase-2 opens on an
approvers.md Approve per contract v3 s19.

## Kapferer scope note
Physique-facet only (visual-consistency mechanics of the gate, not
brand meaning) — this proposal is pure implementation-hygiene remediation
of the role's own tooling, not a Personality/Culture/Relationship/
Reflection/Self-image judgment call. No scoping question arose.

## Precondition check
core issue #72 (gate-house standard) is landed: `core/hooks/lib/gate-lib.sh`,
`core/hooks/lib/gate-lib.py`, `core/hooks/tests/run-gate-lib-tests.sh`,
`core/hooks/tests/compliance-check.sh`, and
`docs/handbooks/gate-house-standard.md` all exist on `tokenmaxxxer-core`
main (verified via `gh api`, full text pulled — see
`docs/issue-13/reports/brand-design/survey.md`). Precondition satisfied;
this proposal follows the handbook's "Per-repo migration checklist"
verbatim.

## Defects addressed (survey.md, all read from the live files)
1. `\S+/\S+` path-token false positive hollowing out asset-spec check.
2. Kill-switch fail-open-on-unrecognized-value (backwards default).
3. `Edit`/`MultiEdit` ignore `replace_all`.
4. Zero Edit/MultiEdit/malformed-JSON/kill-switch/absolute-path test
   coverage.
5. Root README documents 4 nonexistent files.
6. Semantic checks are flat substring membership, not section/adjacency.

## Design: reference-adopt core's gate-lib, never reimplement

Each of the four `brand-design-*/hooks/methodology-gate.sh` gains, at
its top (mirroring `gate-lib.sh`'s own usage comment and
`record-fields-gate.sh`'s existing migration in core):

```bash
. "${CLAUDE_PLUGIN_ROOT_CORE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd -P)}/hooks/lib/gate-lib.sh"
gate_trap_fail_closed          # replaces the hand-rolled __fc/trap pair
set -uo pipefail
gate_kill_switch_active "${BRAND_DESIGN_<NAME>_GATE_OFF:-}" || { trap - EXIT; exit 0; }
```

removing:
- the hand-rolled `__fc`/`trap __fc EXIT` (lines 2-3 of each gate) —
  replaced by `gate_trap_fail_closed`.
- the hand-rolled kill-switch `case` block — replaced by
  `gate_kill_switch_active`, fixing defect 2 for free (this is exactly
  the fix core applied to its own seven gates).
- the hand-rolled `deny()` shell function — replaced by `gate_deny`
  (same stderr+exit-2 contract, so callers change signature only:
  `gate_deny "$role" "$msg"` instead of `deny "$msg"`).

Inside each gate's Python payload (the heredoc), add the
`gate-lib.py` import per its documented usage:

```python
import importlib.util, os
_spec = importlib.util.spec_from_file_location("gate_lib", os.environ["GATE_LIB_PY"])
gate_lib = importlib.util.module_from_spec(_spec); _spec.loader.exec_module(gate_lib)
```

and replace:
- the hand-rolled `json.loads`/`isinstance(ev, dict)` checks →
  `gate_lib.gate_parse_json_or_deny(raw, deny)`.
- the hand-rolled `resolve()` path function → build on
  `gate_lib.gate_normalize_path(root, path)` (string-only tail-normalize;
  gates that need symlink-safety keep their own `os.path.realpath(root)`
  call on `root` first, per `gate_normalize_path`'s documented contract,
  then pass the realpath'd root in — this preserves the current
  behavior of resolving symlinks in `root` while gaining the canon's
  tested normalize-tail logic for `path`).
- the hand-rolled per-tool reconstruction (`Write`/`Edit`/`MultiEdit`
  branches) → one call to
  `gate_lib.gate_reconstruct_write(tool, ti, current)`, fixing defect 3
  for all three tools at once, in all four gates.

This removes every hand-rolled copy of these five shapes from all four
`brand-design-*` gates and replaces each with the single upstream
function — satisfying "자체 재구현 금지" literally, not just in spirit.

## Design: path-token defect (defect 1)

`asset_spec_present`'s `path_or_format` term
(`brand-design-guide-and-spec/hooks/methodology-gate.sh:184`, and the
equivalent term in the other three gates' asset/path checks) drops the
bare `\S+/\S+` fallback entirely. A real asset path is provable only by:
- a file-extension match (already present:
  `\.(svg|png|jpg|jpeg|webp|otf|ttf|woff2?)\b`), or
- a bare hex/rgb value (already covered by the `hex_count` branch).

No other token shape counts as "a path." This closes the false-positive
without narrowing legitimate matches, since every asset-spec example in
the plugin's own README and existing allow-case tests already carries a
real file extension or a hex value.

## Design: semantic check upgrade — substring → section/adjacency (issue
requirement 2, defect 6)

Replace the flat `has_any(...)`/`in low` membership tests with a
two-step check per methodology field:

1. **Section presence**: the field's label (e.g. `asset spec`, `brand
   guide entry`, `WCAG`, `design-system source`) must appear as a
   heading-shaped or label-shaped line — `^\s*#{1,6}\s*<label>` or
   `^\s*<label>\s*:` (case-insensitive), not merely anywhere in the
   flattened text. This is checked line-by-line against `new_text`
   (never lowercased-and-flattened first), so a label buried mid-sentence
   no longer counts.
2. **Adjacency of evidence to claim**: the concrete value (hex/path/WCAG
   ratio/repo path) must occur within that label's own paragraph — the
   span from the label line to the next blank line or next label line —
   not merely anywhere in the whole document. This directly fixes
   defect 1's root cause (a `pass/fail` token three sections away could
   never again satisfy an asset-spec check scoped to the asset-spec
   paragraph) and generalizes it: today's flat `in low` checks in
   `kapferer-scope-guard` (prohibition acknowledgement), `wcag-
   consistency` (ratio+verdict pairing), and `system-handoff` (path
   presence) get the same paragraph-scoping, so a ratio number in one
   section can no longer satisfy a verdict claim made in an unrelated
   section.

Each gate keeps its existing "not applicable: <reason>" / "no new
pairing introduced" early-exit allowance as a paragraph-level alternative
to the concrete-value requirement, unchanged in spirit from today.

## Design: mandatory test cases (issue requirement 3)

Each of the four `hooks/tests/methodology-gate-tests.sh` files gains, on
top of the existing `Write`-only cases, six mandatory groups mirroring
`core/hooks/tests/run-gate-lib-tests.sh`'s own six (per gate-house-
standard.md's "Standard test harness"), adapted to this plugin's
record shape:

1. `Edit` with `replace_all: true` against a multiply-occurring
   `old_string` in the record — asserts the reconstructed text (not just
   the gate's allow/deny) reflects every occurrence replaced.
2. `MultiEdit` with a mix of `replace_all: true`/`false` edits in one
   call.
3. Malformed JSON on stdin (truncated, non-object top level, empty
   payload) — asserts deny, not silent exit-0.
4. Kill-switch env var set to an unrecognized value (e.g. a typo) —
   asserts the gate stays **active** (deny on a would-be-denied record),
   not the current fail-open behavior.
5. Absolute `file_path` reaching the same record a relative-path fixture
   already reaches, plus a `./`-prefixed variant — asserts identical
   allow/deny outcome to the relative-path case.
6. A `Bash`-tool command whose target path (via
   `gate_bash_write_targets`) reaches the same record a `Write`-tool call
   would reach — asserts the gate does not silently exit-0 just because
   the tool name isn't `Write`/`Edit`/`MultiEdit`. (Today's gates only
   branch on `tool in ("Write","Edit","MultiEdit")`; this proposal keeps
   that tool-set for the fields check itself — issue-13 does not ask
   this role's gate to start policing Bash writes — but the test still
   asserts the *existing* documented behavior, "writes outside both
   surfaces exit 0," holds correctly for a Bash-tool call whose target
   is inside the surface but whose tool name the gate does not special-
   case, catching a future accidental behavior change.)

"배송 상태에서 전 스위트 green" (issue requirement 3): phase-2's
completion criterion is `bash hooks/tests/methodology-gate-tests.sh`
exiting 0 in all four plugin directories, run as part of the same
phase-2 record's evidence, plus a copy of
`core/hooks/tests/run-gate-lib-tests.sh` adapted to this repo's gates per
the migration checklist's step 3.

## Design: README ghost-file fix (defect 5, issue requirement 4)

Root `README.md` "Layout" section: remove the four nonexistent-file
lines (`record-fields-gate.sh`, `trailer-gate.sh`,
`handbook-trigger-gate.sh`, `warrant-hunter.md` under `brand-design/`).
Replace with the actual on-disk layout: `brand-design/hooks/hooks.json`,
`brand-design/hooks/directive.sh`, and the four sibling
`brand-design-*/` plugin directories with a one-line pointer to each
plugin's own README (which are already accurate, per survey.md) instead
of re-describing their contents in the root README — this avoids
reintroducing the same drift defect the moment a sibling plugin's gate
changes shape again. Also add a line noting the `core/hooks/lib/
gate-lib.sh` reference-adopt relationship, since that becomes load-
bearing after this migration.

## Compliance evidence (issue requirement 3/4 exit criterion)

Phase-2's record cites `core/hooks/tests/compliance-check.sh
brand-design-*/hooks` run against each of the four plugin hook
directories, clean, as the acceptance evidence — the same evidence form
the gate-house-standard.md migration checklist specifies for every
downstream rulebook's own A+ issue.

## Out of scope for this role (HAND_OFF boundary, unaffected)
No token-systemization work; no change to `core`'s own canon files
(read-only reference). This proposal only touches
`brand-design-*/hooks/methodology-gate.sh`,
`brand-design-*/hooks/tests/methodology-gate-tests.sh`, and the root
`README.md`.
