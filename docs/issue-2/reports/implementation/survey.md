# Current-state survey — issue-2

## Scope note (scout skip record)

Scouting (per the scout directive) is skipped. Reason: this is an internal
architecture follow-through, not a build with an open design decision —
core's own repo already landed the canon (`tokenmaxxxer-core` issues #63/#66,
commits `130cb13`/`2fd1fcb`/`83863de`/`505e5ed`) and its issue-66 report
explicitly names "the per-rulebook follow-up" this issue *is*, with the
target stub shape already fixed by core's `stub-check.sh`. There is no
competing design to survey for; the only work is applying a pinned template
to this one rulebook. (Skip condition: "the spec literally leaves no design
decision open.")

## This repo's current vendored copies

| File | Role in this repo | Canon status per core |
|---|---|---|
| `brand-design/agents/warrant-hunter.md` | full copy of warrant's hunter, adapted mandate text | superseded — core ships `warrant` as an installable plugin (`tokenmaxxxer-core/warrant/agents/warrant-hunter.md`, role-blind); rulebooks reference it, not vendor it (core README: "core, terse, freelunch, scout" pattern; issue-63 proposes the same for warrant) |
| `brand-design/hooks/trailer-gate.sh` | commit-trailer gate, role name substituted | now `core/hooks/trailer-gate.sh`, registered core-side in `core/hooks/hooks.json`, fires for every plugin install automatically (issue-66, approver decision: core-side, not per-rulebook) |
| `brand-design/hooks/record-fields-gate.sh` | §20 record-field gate, `REQUIRED_FIELDS = ["brand-guide-entry","asset-spec","consistency-check"]` | now `core/hooks/record-fields-gate.sh`, core-side; role-unique field list is **not** preserved by core's version — core's canon gate checks a fixed generic field set (what/why/upstream-basis/loop_state/open-findings) per contract §20, not a per-role produces list. This role's own `produces` field names (`brand guide entry, asset spec, consistency check vs existing guide`) are not literally checked by any core gate; they remain a spec-level statement in `directive.sh`'s `PRODUCES:` line and this role's own record content, not gate-enforced. |
| `brand-design/hooks/handbook-trigger-gate.sh` | §21 handbook-trigger gate, placeholder `exit 0` | now `core/hooks/handbook-trigger-gate.sh`, core-side, fully implemented (not a placeholder) |
| `brand-design/hooks/directive.sh` | full boilerplate + 4 role-unique values inline | core factored the boilerplate into `core/hooks/lib/role-directive.sh` (`core_role_directive` function); a rulebook's `directive.sh` should shrink to shebang + trap/pipefail preamble (kept locally per issue-66's report — a trap installed inside a sourced function does not catch the sourcing script's own abnormal exit) + source line + 4 variable assignments + one call |
| `brand-design/hooks/hooks.json` | registers all 3 gates + directive.sh itself | the 3 gate entries are now redundant (core fires them for every plugin install); only the `SessionStart` → `directive.sh` entry stays |

## Role-unique content to preserve (issue's item 2)

From `directive.sh` today:
- `YOU DECIDE: 브랜드 정체성이 시각적으로 일관되는가`
- `USE_WHEN: 브랜드 자산 신설/변경이 걸릴 때`
- `PRODUCES (required record fields): brand guide entry, asset spec, consistency check vs existing guide`
- `WRITE_SCOPE: design-system source paths (TBD at execution)` — note: `core_role_directive`'s signature (per `role-directive.sh` source) takes exactly 4 args (`you_decide`, `use_when`, `produces`, `hand_off`); today's file has a 5th line (`WRITE_SCOPE`) with no equivalent slot in the canon function. Needs a decision in the proposal (see below).
- `HAND-OFF: 토큰 시스템화 구현은 → ux-engineering`
- `BOUNDARY CASE: ...` paragraph — also has no slot in `core_role_directive`'s fixed template (which only renders the 4 values plus the fixed `RECORD:` closing line).

## Item 4 (terminal-state divergence) applicability

Core's `record-fields-gate.sh` is now a fixed-field checker (what-was-done /
why / upstream-basis / loop_state / open-findings), independent of this
role's own `produces` list, and defaults `RECORD_FIELDS_TERMINAL_STATES` to
`landed`. This repo's own record vocabulary (per `directive.sh`'s `RECORD:`
line and contract v3 s19) uses `loop_state` values that are not yet
established for this role beyond the skeleton — no existing
`docs/issue-*/reports/brand-design.md` exists yet to check against a
non-`landed` terminal set. Nothing in this rulebook's current state shows a
divergent terminal-state need; default (`landed`-only) applies unless a
future record shows otherwise.

## Item 5 (stub-check.sh)

`core/hooks/tests/stub-check.sh` does not exist anywhere in this repo yet.
It needs to be copied in (core distributes it "the way `parse-check.sh`
already is... dropped into every rulebook"). This repo currently has no
`hooks/tests/` directory and no test harness at all (`parse-check.sh`,
`deny-only-check.sh`, `run-all.sh` are absent) — running `stub-check.sh`
here is a bare invocation against `brand-design/hooks/`, not integration
into an existing suite.

## Order constraint carried forward

Per the issue: this migration must land before this rulebook's own
"maturation" phase-2 issue (the skeleton's own hardening — e.g. the
`handbook-trigger-gate.sh` and `record-fields-gate.sh` placeholders/TODOs
seeded in `d3e35da`) starts its phase 2, to avoid that phase-2 touching
files this promotion deletes.
