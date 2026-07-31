---
subject: issue-5
role: implementation
loop_state: open
---

# Proposal — reclaim vendored `stub-check.sh` copy (core #69 canon)

## Change

1. Delete `brand-design/hooks/tests/stub-check.sh` (verbatim vendored
   copy, added in issue-2's phase 2 before core #69's "reference, never
   copy" canon existed).
2. No `hooks.json` change needed — confirmed no `stub-check.sh` entry is
   registered there (only `directive.sh` is).
3. Replace the manual invocation with the core-referenced form from core's
   `docs/handbooks/role-gates-tests.md`:

       "${CORE_PLUGIN_ROOT:-$CLAUDE_PLUGIN_ROOT/../core}/hooks/tests/stub-check.sh" "$(dirname "$0")/.."

   No wrapper script exists to hold this in this repo (no `run-all.sh`
   equivalent) — phase 2 runs it directly as a shell invocation against
   `brand-design/hooks` and records the resolved path plus pass/fail
   output, per `reclaim-21-copies.md` step 3's verification shape.
4. Record the pass in `docs/issue-5/reports/implementation.md`, replacing
   the now-stale vendored-copy invocation note left in
   `docs/issue-2/reports/implementation.md`.

## Why this order

Core issue-69's own rollout doc
(`docs/issue-69/reports/implementation/reclaim-21-copies.md`) prescribes
exactly this delete-and-reference-and-verify sequence and flags that the
`${CLAUDE_PLUGIN_ROOT}/../core` sibling path needs confirming against a
real install rather than assumed — phase 2 verifies this live instead of
copying the invocation line untested.

## Out of scope for this proposal

- The other four canon files (`trailer-gate.sh`, `record-fields-gate.sh`,
  `handbook-trigger-gate.sh`, `parse-check.sh`) are already absent from
  this rulebook's tree — nothing to reclaim there.
- No `run-all.sh`-style harness exists in this repo to wire the
  invocation into; creating one is not requested by issue #5 and is not
  added here.

## Phase-2 acceptance

- `brand-design/hooks/tests/stub-check.sh` no longer exists in this repo.
- The core-referenced invocation above runs successfully against
  `brand-design/hooks` and exits 0.
- `docs/issue-5/reports/implementation.md` records the invocation used,
  the resolved core path, and the pass output.
