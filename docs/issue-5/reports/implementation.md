---
subject: issue-5
role: implementation
loop_state: landed
---

# Record — reclaim vendored `stub-check.sh` copy (core #69 canon)

## What was done

1. Deleted `brand-design/hooks/tests/stub-check.sh` (verbatim vendored
   copy of core canon, added in issue-2's phase 2 before core #69's
   "reference, never copy" canon existed).
2. `brand-design/hooks/hooks.json` confirmed unchanged: it registers only
   `directive.sh` under `SessionStart`; no `stub-check.sh` entry was ever
   present, so no removal was needed there.
3. Ran the core-referenced invocation and recorded the pass below.

## Why

Basis: core issue-69's rollout doc,
`docs/issue-69/reports/implementation/reclaim-21-copies.md` (core repo),
and `docs/handbooks/canon-scripts.md` (core repo) — canon scripts,
including `stub-check.sh` itself, are referenced from the core install,
never vendored into a rulebook. This repo's copy was drift from before
that canon existed; issue #5 requests reclaiming it, per the approved
proposal at `docs/issue-5/proposals/2026-07-31-stub-check-canon-reclaim.md`.

## Core-referenced invocation, resolved and run

Resolved core plugin root on this install:
`/home/jwjung/tokenmaxxxer/tokenmaxxxer-core/core`.

Ran:

    CORE=/home/jwjung/tokenmaxxxer/tokenmaxxxer-core/core
    bash "$CORE/hooks/tests/stub-check.sh" "brand-design/hooks"

Output (exit 0):

    stub-check: ok — no vendored 'trailer-gate.sh' under brand-design/hooks
    stub-check: ok — no vendored 'record-fields-gate.sh' under brand-design/hooks
    stub-check: ok — no vendored 'handbook-trigger-gate.sh' under brand-design/hooks
    stub-check: ok — no vendored 'parse-check.sh' under brand-design/hooks
    stub-check: ok — no vendored 'stub-check.sh' under brand-design/hooks
    stub-check: ok — brand-design/hooks/directive.sh is a role-directive stub

Before the deletion, the same invocation failed with:

    stub-check: FAIL — vendored copy of core canon file 'stub-check.sh' found:
    brand-design/hooks/tests/stub-check.sh

confirming the check actually detects the vendored copy and passes clean
after its removal.

## Note on the stale note in issue-2's record

`docs/issue-2/reports/implementation.md` still documents the now-deleted
manual vendored-copy invocation as historical record of that issue's
phase-2 work; it is out of this branch's write scope (board-gate
restricts `docs/issue-2/` writes to the `issue-2/implementation` branch)
and is left as-is — it reflects what was true at the time it was written.

## Result

- `brand-design/hooks/tests/stub-check.sh` no longer exists in this repo.
- `hooks.json` has no `stub-check.sh` registration.
- The core-referenced invocation runs and exits 0 against
  `brand-design/hooks`.

## Open findings

None. Both phase-2 acceptance criteria from the proposal are met, and
the vendored file's removal is verified by the passing core-referenced
`stub-check.sh` run above.
