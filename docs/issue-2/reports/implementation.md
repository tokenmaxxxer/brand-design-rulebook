---
subject: issue-2
role: implementation
loop_state: landed
---

# Record: core canon reference switch (issue-2)

## What was done / why

Approved proposal (`docs/issue-2/proposals/2026-07-31-core-canon-reference-switch.md`)
executed in one batch: this rulebook's vendored copies of the warrant-hunter
agent and the three role-agnostic gates are removed in favor of core canon
(`tokenmaxxxer-core` issues #63/#66); `directive.sh` is reduced to a stub
sourcing `core_role_directive`.

## Upstream basis

- core issue #63 (warrant plugin) and #66 (role-agnostic gates + directive
  boilerplate promoted to `core/hooks/`), both landed on `tokenmaxxxer-core`
  main.
- `docs/issue-2/proposals/2026-07-31-core-canon-reference-switch.md`,
  approved via issue comment `APPROVE issue-2/implementation`.

## Changes made

1. Deleted `brand-design/agents/warrant-hunter.md` — core's `warrant`
   plugin ships a role-blind `warrant-hunter.md` that reads stance/mandate
   from the dispatching session; nothing role-unique was lost.
2. Deleted `brand-design/hooks/trailer-gate.sh`,
   `brand-design/hooks/record-fields-gate.sh`,
   `brand-design/hooks/handbook-trigger-gate.sh` and dropped their
   `PreToolUse` entries from `brand-design/hooks/hooks.json` (core
   registers all three core-side; `hooks.json` now carries only the
   `SessionStart` → `directive.sh` entry).
3. Rewrote `brand-design/hooks/directive.sh` as a stub: sources
   `core/hooks/lib/role-directive.sh` and calls `core_role_directive` with
   this role's four values. Per the proposal's option (b), `WRITE_SCOPE`
   was folded into `PRODUCES` as a trailing clause (`design-system source
   paths`); `BOUNDARY CASE` was dropped from the per-session directive (no
   slot in `core_role_directive`'s template) — its hand-off rule is
   preserved here in the record rather than restated at every SessionStart,
   pending a future `docs/handbooks/` entry for this role.
4. No `RECORD_FIELDS_TERMINAL_STATES` override added — no existing
   `brand-design.md` record showed a divergent terminal `loop_state` need,
   matching the proposal's finding. Core's `landed`-only default applies.
5. Copied `core/hooks/tests/stub-check.sh` verbatim to
   `brand-design/hooks/tests/stub-check.sh`.
6. Added a `dependencies` note to `brand-design/.claude-plugin/plugin.json`
   documenting that this plugin requires `core` and `warrant` from
   `tokenmaxxxer-core` installed alongside it (installation itself is
   on-the-record's job, not this repo's).

## Behavior change flagged in the proposal

`record-fields-gate.sh`'s core canon version checks a fixed generic §20
field set, not this role's former role-specific list
(`brand-guide-entry`, `asset-spec`, `consistency-check`). Accepted as
intended per core's issue-66 report (enforcement consolidated into
structure, not per-role vocabulary).

## Verification

`bash brand-design/hooks/tests/stub-check.sh brand-design/hooks` — **PASS**
(exit 0). Output:

```
stub-check: ok — no vendored 'trailer-gate.sh' under brand-design/hooks
stub-check: ok — no vendored 'record-fields-gate.sh' under brand-design/hooks
stub-check: ok — no vendored 'handbook-trigger-gate.sh' under brand-design/hooks
stub-check: ok — no vendored 'parse-check.sh' under brand-design/hooks
stub-check: ok — brand-design/hooks/directive.sh is a role-directive stub
```

`hooks.json` contains no reference to any of the three deleted gate
filenames; `agents/warrant-hunter.md` and the three gate `.sh` files no
longer exist under `brand-design/`.

## Open findings

None.
