---
code_under_review: brand-design-guide-and-spec/hooks/tests/methodology-gate-tests.sh, brand-design-kapferer-scope-guard/hooks/tests/methodology-gate-tests.sh, brand-design-system-handoff/hooks/tests/methodology-gate-tests.sh, brand-design-wcag-consistency/hooks/tests/methodology-gate-tests.sh
type: test
breaking: false
verdict: pass
loop_state: landed
---

# Implementation record — issue #23

## Summary of work
Adopted the on-the-record issue #551 test-env resolution convention in
all four `hooks/tests/methodology-gate-tests.sh` scripts
(`brand-design-guide-and-spec`, `brand-design-kapferer-scope-guard`,
`brand-design-system-handoff`, `brand-design-wcag-consistency`). Each
script now runs a native-bash `_resolve_core()` block before any
gate subprocess: `$CLAUDE_PLUGIN_ROOT_CORE` (non-empty `gate-lib.sh`) →
sibling candidate `../../../core` relative to `hooks/tests/` (non-empty
`gate-lib.sh`) → SKIP with the exact convention message, exit `75`.
`wcag-consistency`'s prior hardcoded sibling-path export line was
replaced by the same resolver, keeping its old candidate as a secondary
fallback after `../../../core`. Every block comments the convention
doc's path so `grep -rl test-env-resolution` matches all four. Landed
as commit f914216 on this branch.

## Why
Per approved proposal `docs/issue-23/proposals/2026-08-09-test-env-resolution-adoption.md`
and issue #23: outside the spawn env, these scripts failed with
misleading `FAIL` lines (gate's own guarded `gate-lib.sh` source failing
closed) instead of a clear SKIP verdict.

## Upstream basis
docs/issue-23/proposals/2026-08-09-test-env-resolution-adoption.md

## What was verified
- `env -u CLAUDE_PLUGIN_ROOT_CORE bash <script>` on all four: prints the
  exact SKIP message to stderr, exits `75`, zero FAIL lines.
- `bash <script>` with `CLAUDE_PLUGIN_ROOT_CORE` set to the real core
  checkout (this session's spawn env): 20/20, 17/17, 19/19, 18/18 passing
  — identical to the survey's pre-change baseline, no regressed
  assertion.
- `grep -rl test-env-resolution` on all four `hooks/tests/` dirs returns
  all four scripts.

## What did not work
None.

## Doc placement
- No new env var, dependency, or migration introduced — nothing to add
  to a handbook.
- No library-or-format choice beyond what the approved proposal's
  Rationale already recorded (native bash vs. vendoring Python vs.
  shared helper lib) — no separate decisions/ entry needed.

## Open findings
None outstanding for this issue.

## Hunt cadence
diff scope: 4 files, ~100 lines added, all under repo root (not
docs-only) — size bucket 21-200 lines per warrant-directive. Prior
after-proposal hunt is on record at
`docs/reports/2026-08-09-hunt-test-env-resolution-adoption.md`. This
headless single-shot session does not dispatch a second background
hunter it cannot wait on and consume within this turn (contract v3 s22
takes priority over the warrant-directive's before-landing dispatch in
this constraint); no finding is outstanding from the after-proposal
hunt to act on.
