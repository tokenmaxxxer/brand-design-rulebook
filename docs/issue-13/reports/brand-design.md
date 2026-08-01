# issue-13 phase-2 record (brand-design gate-house A+ remediation)

loop_state: landed

## what was done

Migrated all four `brand-design-*/hooks/methodology-gate.sh` +
`hooks/tests/methodology-gate-tests.sh` onto the core gate-house standard
(core issue #72's `gate-lib.sh`/`gate-lib.py`), per the approved
`docs/issue-13/proposals/2026-08-01-brand-design-gate-house-migration.md`:

- Every gate now sources `gate-lib.sh` first, calls `gate_trap_fail_closed`
  as the first executable statement (before `set -uo pipefail`), and uses
  `gate_kill_switch_active` for its kill switch — removing the hand-rolled
  `__fc`/`trap __fc EXIT` pair and the `case ... in ""|0|false|no|off) ;;
  *) exit 0 ;; esac` idiom. Fixes defect 2 (fail-open on an unrecognized
  kill-switch value) for free in all four gates.
- Every gate's Python payload now loads `gate-lib.py` via `importlib`
  (`os.environ["GATE_LIB_PY"]`) and calls `gate_parse_json_or_deny`,
  `gate_normalize_path`, and `gate_reconstruct_write` instead of hand-rolled
  JSON parsing, path resolution, and per-tool Write/Edit/MultiEdit
  reconstruction. Fixes defect 3 (`replace_all` ignored on Edit/MultiEdit)
  in all four gates.
- `brand-design-guide-and-spec`'s `asset_spec_present` check dropped the
  bare `\S+/\S+` path-token fallback entirely (fixes defect 1 — a
  `pass/fail`-shaped token no longer counts as an asset path). An asset
  path is now provable only by file-extension match or a hex/rgb value.
- All four gates' semantic checks were rewritten from flat
  substring/`in low` membership over the whole flattened, lowercased
  document to section/adjacency-scoped checks: a field's label must appear
  as its own heading- (`^\s*#{1,6}\s*<label>`) or label-shaped
  (`^\s*<label>\s*:`) line (case-insensitive, checked line-by-line against
  the un-flattened `new_text`), and the concrete value/claim must occur
  within that label's own paragraph (label line to the next blank line or
  next label line). `wcag-consistency`'s ratio+verdict pairing, in
  particular, can no longer be satisfied by a ratio in one section pairing
  with a verdict claimed in an unrelated section (fixes defect 6).
- All four `hooks/tests/methodology-gate-tests.sh` gained the six mandatory
  case groups (`run-gate-lib-tests.sh`'s shape, adapted to each gate's own
  record shape): Edit with `replace_all: true` against a
  multiply-occurring `old_string`; MultiEdit with mixed `replace_all`
  true/false edits; malformed JSON (truncated / non-object / empty);
  kill-switch set to an unrecognized value (asserts the gate stays
  ACTIVE); absolute `file_path` and a `./`-prefixed variant reaching the
  same record a relative-path fixture reaches; a non-Write/Edit/MultiEdit
  tool call (documents the existing out-of-scope exit-0 behavior). Fixes
  defect 4 (zero Edit/MultiEdit/malformed-JSON/kill-switch/absolute-path
  coverage). `wcag-consistency` additionally carries a case proving the
  paragraph-scoping fix directly (cross-section ratio/verdict pairing
  denied; co-located pairing allowed).
- Root `README.md` "Layout" section rewritten to name the actual on-disk
  layout (the four `brand-design-*/` plugin directories, each pointing to
  its own accurate README) instead of the four nonexistent
  `brand-design/hooks/*.sh` + `brand-design/agents/warrant-hunter.md`
  files it previously documented (fixes defect 5), plus a line on the
  `gate-lib.sh` reference-adopt relationship.

Full suite result (`bash hooks/tests/methodology-gate-tests.sh` in each of
the four plugin directories, `CLAUDE_PLUGIN_ROOT_CORE` pointed at a local
`tokenmaxxxer-core` checkout carrying the landed issue-#72 `gate-lib.sh`/
`gate-lib.py`): **65 passed, 0 failed** across all four suites combined
(guide-and-spec 18, kapferer-scope-guard 15, system-handoff 16,
wcag-consistency 16), all green.

`core/hooks/tests/compliance-check.sh <plugin>/hooks` run against each of
the four plugin hook directories: all four report `compliance-check: ok`
for `methodology-gate.sh` — no gate reads a `*_OFF` var without
`gate_kill_switch_active`, and no gate hand-rolls its own
`.replace(o, n[, 1])` instead of `gate_reconstruct_write`.

## why

Issue #13's 2026-08-01 code audit graded this role's gate-house tooling
B-: a path-token false positive hollowing out the asset-spec check, a
backwards (fail-open) kill switch, `replace_all` ignored on Edit/MultiEdit,
zero non-Write test coverage, and a root README documenting four
nonexistent files. core issue #72 landed the shared `gate-lib.sh`/
`gate-lib.py` + `compliance-check.sh` this role's own remediation was
required to reference-adopt rather than re-fix by hand, per
`docs/handbooks/gate-house-standard.md`'s per-repo migration checklist.
The approved phase-1 proposal
(`docs/issue-13/proposals/2026-08-01-brand-design-gate-house-migration.md`)
designed exactly this migration; this record delivers it.

## upstream basis

- `docs/issue-13/proposals/2026-08-01-brand-design-gate-house-migration.md`
  (this role's own approved phase-1 proposal)
- `docs/issue-13/reports/brand-design/survey.md` (this role's own phase-1
  current-state survey)
- tokenmaxxxer-core `docs/handbooks/gate-house-standard.md` and
  `core/hooks/lib/gate-lib.sh` / `gate-lib.py` / `core/hooks/tests/
  compliance-check.sh` / `core/hooks/tests/run-gate-lib-tests.sh` (issue
  #72, landed)
- accessibility-rulebook's `wcag-em-gate/hooks/methodology-gate.sh` (a
  real precedent of another downstream rulebook already migrated onto
  `gate-lib.sh`, used as the structural template for the source-line /
  trap / kill-switch / importlib-loading shape)

## deviation from the proposal's migration-checklist step 3, and why

The proposal's "Compliance evidence" section cites, alongside the four
plugins' own adapted test suites, "a copy of `core/hooks/tests/
run-gate-lib-tests.sh` adapted to this repo's gates per the migration
checklist's step 3." That script tests `gate-lib.sh`/`gate-lib.py`'s own
functions directly (kill-switch spellings, JSON parsing, path
normalization, Write/Edit/MultiEdit/NotebookEdit reconstruction) — it is
not role-specific, and copying it into this repo would vendor a second
implementation of the exact generic library-level test the "reference
only, never copy" canon-scripts rule this proposal itself invokes (`자체
재구현 금지`) argues against duplicating. In practice, the six mandatory
case groups it requires are already the case groups added to each of the
four `brand-design-*` plugins' own `methodology-gate-tests.sh` files
(described above), exercised against each gate's *real* subprocess
behavior rather than against `gate-lib.py`'s functions in isolation — a
strictly stronger evidence form for this repo's own remediation issue,
since it proves the fixes actually reached each gate's behavior, not just
that the upstream library is internally correct (core issue #72's own
`run-gate-lib-tests.sh` run already covers that). No separate vendored
copy of `run-gate-lib-tests.sh` was added to this repo for that reason.

## open findings

None outstanding for this issue's scope. Two items worth a future
role/issue's attention, out of scope here:

- `brand-design/hooks/hooks.json` wiring for the four `brand-design-*`
  plugins' `methodology-gate.sh` was not touched by this remediation
  (issue-13's scope was the gate logic itself, not wiring) — verify
  separately that `hooks.json` in each plugin actually invokes
  `methodology-gate.sh` on `PreToolUse` as documented.
- `CLAUDE_PLUGIN_ROOT_CORE` resolution for a standalone (non-marketplace)
  checkout of this repo depends on a sibling `core/` directory existing at
  `<repo-root>/../core` unless the env var is set explicitly — this repo
  itself carries no `core/` directory (by design; the library is
  reference-only). Verification for this record was run with
  `CLAUDE_PLUGIN_ROOT_CORE` pointed at a local `tokenmaxxxer-core`
  checkout; a marketplace install resolves this via
  `CLAUDE_PLUGIN_ROOT_CORE` set by the plugin host at runtime, matching
  the same convention `wcag-em-gate`'s prior migration already relies on.
