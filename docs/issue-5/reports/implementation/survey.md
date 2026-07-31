---
subject: issue-5
role: implementation
loop_state: open
---

# Survey — vendored `stub-check.sh` copy in this rulebook

## What exists

- `brand-design/hooks/tests/stub-check.sh` — verbatim copy of core's
  `core/hooks/tests/stub-check.sh`, added in issue-2's phase-2 work
  (`docs/issue-2/reports/implementation.md` step 5, per the proposal at
  `docs/issue-2/proposals/2026-07-31-core-canon-reference-switch.md`
  section 5). At the time of that write, core canon's own guidance called
  for a verbatim copy — this predates core issue-69's "reference, never
  copy" canon.
- `brand-design/hooks/hooks.json` — registers only `directive.sh`
  (`SessionStart` hook). **No `stub-check.sh` entry exists in hooks.json.**
  `stub-check.sh` has only ever been invoked manually
  (`bash brand-design/hooks/tests/stub-check.sh brand-design/hooks`,
  recorded in `docs/issue-2/reports/implementation.md`), not wired as a
  hook or into any `run-all.sh`-equivalent harness — this repo has none.

## Core canon (issue-69)

- `docs/handbooks/canon-scripts.md` (core repo): "Canon scripts are
  referenced, never copied." Applies to every file under
  `core/hooks/tests/canon-manifest.txt`, which explicitly lists
  `stub-check.sh` itself alongside the three role-agnostic gates and
  `parse-check.sh`.
- `docs/handbooks/role-gates-tests.md` (core repo), "Canon invocation from
  a rulebook": the sanctioned replacement invocation is

      "${CORE_PLUGIN_ROOT:-$CLAUDE_PLUGIN_ROOT/../core}/hooks/tests/stub-check.sh" "$(dirname "$0")/.."

  Flags that the exact `${CLAUDE_PLUGIN_ROOT}` sibling-resolution
  expression needs confirming against a real marketplace install before
  copying verbatim — this repo's checkout has no sibling `core/` install
  to test against directly.
- `docs/issue-69/reports/implementation/reclaim-21-copies.md` (core repo):
  documented rollout procedure for the 21 known vendored copies across
  external rulebooks — delete-and-reference, verify, batched with
  issue-63/issue-66 follow-ups. Execution against this repo is exactly
  this issue (#5).

## Gap line

- **Missing vs. canon:** the vendored file itself (drift target #1) and
  the stale invocation instructions in
  `docs/issue-2/reports/implementation.md` / proposal that assume a local
  copy.
- **Already met:** hooks.json has no `stub-check.sh` entry to strip —
  nothing to remove there. The four role-agnostic gate files
  (`trailer-gate.sh` etc.) and `parse-check.sh` are already absent from
  this rulebook's tree (confirmed by the existing stub-check pass log in
  the issue-2 record) — only `stub-check.sh` itself is the outstanding
  vendored copy.
- **Unconfirmed:** the exact `${CLAUDE_PLUGIN_ROOT}/../core` sibling path
  resolution in a real marketplace install of this rulebook. Per the core
  handbook's own caveat, this should be verified against one pilot
  invocation before being treated as final — phase 2 will run it and
  record the actual result rather than assume it resolves.

## Scout skip record

Skipped per scout-directive's bugfix-shaped skip condition: this is a
canon-rollout mechanical task with the target state, exact replacement
invocation, and rollout procedure already fully specified by core issue-69
handbooks and reclaim doc — no open design decision remains to scout
exemplars for.
