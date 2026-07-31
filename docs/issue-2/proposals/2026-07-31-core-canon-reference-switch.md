---
subject: issue-2
role: implementation
loop_state: scope-proposed
---

# Proposal: switch this rulebook to core canon references (issue-2)

## Request (paraphrased intent)

Core landed a single canon for the warrant-hunt agent (core issue #63) and
the three role-agnostic gates + directive boilerplate (core issue #66).
This rulebook still vendors byte copies of all of it. Replace the vendored
copies with references to core canon in one batch, preserving this role's
own genuinely unique content. See `docs/issue-2/reports/implementation/survey.md`
for the full current-state audit this proposal is built on.

## Constraints

- Phase-1 only — no file is deleted or edited outside `docs/issue-2/**` in
  this PR. Phase 2 executes only after Approve.
- Scouting skipped — recorded in survey.md's Scope note: this is a pinned
  follow-through on core's own already-landed design (core issues #63/#66),
  not an open design question.
- Order constraint from the issue: this must complete before this
  rulebook's own maturation-issue phase 2 starts.
- Write set for phase 2 (frozen, listed so it can be reviewed before
  approval):
  - delete `brand-design/agents/warrant-hunter.md`
  - delete `brand-design/hooks/trailer-gate.sh`
  - delete `brand-design/hooks/record-fields-gate.sh`
  - delete `brand-design/hooks/handbook-trigger-gate.sh`
  - rewrite `brand-design/hooks/directive.sh` (stub form)
  - rewrite `brand-design/hooks/hooks.json` (drop the 3 gate entries)
  - add `brand-design/hooks/tests/stub-check.sh` (copied verbatim from core)
  - `brand-design/.claude-plugin/plugin.json` — add a `dependencies`/README
    note that this plugin requires `core` and `warrant` from
    `tokenmaxxxer-core` installed alongside it (on-the-record's job to
    actually install; this file only documents the requirement, matching
    how `terse`/`freelunch`/`scout` document theirs)
  - `docs/issue-2/reports/implementation.md` (phase-2 record; written after
    Approve, per contract v3 s19)

## What will be done (phase 2 only — not applied yet)

### 1. Remove the warrant-hunter copy → reference core's `warrant` plugin

Delete `brand-design/agents/warrant-hunter.md`. This role has no
agent-level customization to preserve here — the file's only "unique" part
was the mandate line (`브랜드 정체성이 시각적으로 일관되는가`) and the
hand-off note, both of which already live in `directive.sh`'s `YOU_DECIDE`/
`HAND_OFF` values and in the warrant proposal-gate's per-request context, not
in the agent file itself. Core's `warrant/agents/warrant-hunter.md` is
role-blind by design (reads its stance and mandate from the dispatching
session's own directive, not from a per-role copy) — nothing is lost.

### 2. Remove the 3 gate copies + their `hooks.json` registrations

Delete `trailer-gate.sh`, `record-fields-gate.sh`, `handbook-trigger-gate.sh`.
Core registers all three core-side (`core/hooks/hooks.json`'s `PreToolUse`
block) per the issue-66 approver decision — they fire for every plugin
install automatically. Remove the matching `PreToolUse` entries from this
repo's own `brand-design/hooks/hooks.json`; keep only the `SessionStart` →
`directive.sh` entry.

Note (survey finding): this role's local `record-fields-gate.sh` copy
checked a role-specific field list (`brand-guide-entry`, `asset-spec`,
`consistency-check`) that core's canon gate does **not** replicate — core's
version checks a fixed generic §20 field set instead. This is a real
behavior change, not a wash: after this switch, a write to
`docs/issue-<n>/reports/brand-design.md` is no longer blocked for omitting
this role's specific three produces-fields, only for omitting the generic
what/why/upstream-basis/loop_state/open-findings set. This proposal accepts
that change as intended by the core promotion (per core's issue-66 report,
architecture-level enforcement is being consolidated into structure, not
per-role vocabulary) rather than reintroducing a role-specific check
core deliberately dropped. Flagged for the approver as the one substantive
behavior change in this batch, not a pure mechanical deletion.

### 3. `directive.sh` → stub sourcing `core_role_directive`

Replace with:

```bash
#!/usr/bin/env bash
trap 'rc=$?; if [ "$rc" != 0 ] && [ "$rc" != 2 ]; then exit 2; fi' EXIT
set -uo pipefail
. "${CLAUDE_PLUGIN_ROOT_CORE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd -P)}/hooks/lib/role-directive.sh"
core_role_directive \
  "YOU DECIDE: 브랜드 정체성이 시각적으로 일관되는가" \
  "USE_WHEN: 브랜드 자산 신설/변경이 걸릴 때" \
  "PRODUCES (required record fields): brand guide entry, asset spec, consistency check vs existing guide" \
  "HAND-OFF: 토큰 시스템화 구현은 → ux-engineering"
```

Two lines from today's file have **no slot** in `core_role_directive`'s
fixed 4-argument template (survey finding): the `WRITE_SCOPE:` line and the
`BOUNDARY CASE:` paragraph. Options, for the approver to pick between:

- (a) drop both — core's canon directive only ever renders 4 values plus its
  own fixed `RECORD:` closing line; every other rulebook that already
  stubbed (`core`/`terse`/`freelunch`/`scout` are session plugins, not
  directive-emitting roles, so there is no existing precedent rulebook stub
  to diff against in this repo's own workspace) would need the same
  treatment, so keeping `brand-design` consistent with the canon's actual
  shape means these lines stop being emitted at SessionStart.
- (b) fold `WRITE_SCOPE` into the `PRODUCES` value (it is closely related —
  both describe what this role is scoped to touch) and drop `BOUNDARY CASE`
  as boilerplate-shaped standing guidance that belongs in a handbook, not a
  per-session directive.

This proposal recommends **(b)**: `WRITE_SCOPE` folds into `PRODUCES` as a
trailing clause; `BOUNDARY CASE` moves to a one-line note in this role's
future `docs/handbooks/` entry rather than being lost outright, since it
states a real hand-off rule (stop and hand off rather than absorb another
role's scope) that is worth keeping *somewhere*, just not duplicated
verbatim in every SessionStart directive when core's canon has no slot for
it.

### 4. Terminal-state config

Per survey: no evidence today of a divergent terminal-state need for this
role (no existing `brand-design.md` record to check against). No
`RECORD_FIELDS_TERMINAL_STATES` override is added in phase 2; core's
`landed`-only default applies. If a future record shows this role treats an
earlier `loop_state` as terminal, that becomes its own follow-up, not part
of this batch.

### 5. `stub-check.sh` pass, recorded

Copy `core/hooks/tests/stub-check.sh` verbatim into
`brand-design/hooks/tests/stub-check.sh` (this repo has no existing test
harness to wire it into, per survey — it runs standalone:
`bash brand-design/hooks/tests/stub-check.sh brand-design/hooks`). Phase 2's
record (`docs/issue-2/reports/implementation.md`) states the pass/fail
result verbatim, per the issue's item 5.

## What is deliberately out of scope

- Installing the `core`/`warrant` plugins into any live session — that is
  on-the-record's job (per core's README: "on-the-record enables them per
  role; nothing else needs to"), not a file this repo can write.
- Hardening the still-placeholder gate logic this repo's own skeleton
  seeded (`handbook-trigger-gate.sh`'s `exit 0 # placeholder`,
  `record-fields-gate.sh`'s substring-match TODO) — moot once those files
  are deleted in favor of core's fully-implemented versions; not this
  role's maturation-issue scope either way.
- Any change to `brand-design/.claude-plugin/plugin.json`'s `name`/
  `description`/`author` fields beyond adding the dependency note.

## How this will be judged

- `stub-check.sh` exits 0 against `brand-design/hooks/` post-change.
- `hooks.json` contains no reference to any of the three deleted gate
  filenames.
- `directive.sh` matches the structural stub shape `stub-check.sh` checks
  for (source line + `core_role_directive` call, no regrown boilerplate).
- `agents/warrant-hunter.md` and the three gate `.sh` files no longer exist
  under `brand-design/`.
