---
subject: issue-10
role: brand-design
loop_state: landed
---

# Record — methodology plugin set (issue-10, phase 2)

## What was done

Built the plugin set described in the approved proposal
(`docs/issue-10/proposals/2026-07-31-brand-design-directive-hardening.md`)
after the approver's `APPROVE issue-10/brand-design` issue comment
(single-account mode, contract v3 §19). Four self-contained plugins, each
owning exactly one methodology concern from the issue-1 charter
(`docs/issue-1/proposals/2026-07-31-brand-design-methodology-charter.md`):

- **brand guide entry**: not applicable — this record's own content is
  the deliverable (a methodology-machinery build, not a brand asset
  change); no logo/color/typography rule is being authored here.
- **asset spec**: not applicable, same reason — the "assets" produced by
  this phase-2 work are the plugin directories and gate scripts listed
  below (`brand-design-guide-and-spec/`, `brand-design-wcag-consistency/`,
  `brand-design-system-handoff/`, `brand-design-kapferer-scope-guard/`),
  not a brand visual asset.

Per plugin: `.claude-plugin/plugin.json`, `hooks/hooks.json`
(`PreToolUse`, matcher `Write|Edit|MultiEdit`), `hooks/
methodology-gate.sh` (fail-closed, own kill-switch env var, modeled on
`pricing-rulebook/pricing/hooks/methodology-gate.sh` — referenced, not
copied), `hooks/tests/methodology-gate-tests.sh` (colocated, real
subprocess, allow/deny cases per the proposal's named-case list — all
pass locally), and `README.md`. `.claude-plugin/marketplace.json` was
extended with all four plugin entries alongside the existing `brand-design`
entry (no entry removed). The base `brand-design/hooks/directive.sh` was
deepened per the proposal's section (a): the `YOU_DECIDE` line now
states the Kapferer Physique-facet scope boundary, `PRODUCES` states
each judgment rule explicitly (not just a noun list) and adds the
`PROHIBITIONS` block, and `HAND_OFF` gained the "stop and hand off"
imperative — each clause tagged with the plugin that authors/enforces
it, `core_role_directive`'s existing four-argument call shape unchanged.
`docs/handbooks/brand-design/methodology.md` was added (phase-1/phase-2
checklists, modeled on `pricing-rulebook/docs/handbooks/pricing/
methodology.md`'s split).

## Consistency check vs existing guide

no new text/background pairing introduced — this record does not touch
any visual color pairing; it is methodology-machinery documentation.

## Design-system source paths

Not applicable this phase — no design-system source path was touched or
handed off; `ux-engineering/` was not read or written by this work.

## Prohibitions

- undocumented color/font introduced silently: not triggered — no color
  or font values were introduced in this phase-2 work.
- WCAG number omitted or replaced with "looks fine": not triggered — see
  "Consistency check vs existing guide" above (explicit early exit).
- token-systemization work performed by this role: not triggered — no
  `ux-engineering/` path was touched; the `HAND_OFF` boundary was kept
  as designed (design-system source paths remain a `brand-design`
  *statement*, never a build, per `brand-design-system-handoff`).

## Why

State-tracking was not built, per the proposal's explicit design
decision (section (b)): the charter's methodology has no cross-turn
ordering constraint the way `coding/verify`'s finding-resolution loop
does; each plugin's per-write field-presence check already enforces the
only ordering that matters (a *finished* write contains that plugin's
required element(s), at write time). Tests were colocated per plugin
(`brand-design-<suffix>/hooks/tests/methodology-gate-tests.sh`) rather
than a repo-root `tests/` directory, per the proposal's recommendation
and this repo's existing convention (no repo-root `tests/` precedent,
per issue-5's survey). No `agents/` subagent was added for any plugin —
the charter's required-components list is checklist-shaped, not a
repeated multi-step procedure a subagent would run (unchanged decision
from phase-1, section (e)).

## What did not work

The kapferer-scope-guard gate's phase-2 test (`kill-switch-off`) first
failed under `set -uo pipefail` in the test harness: the gate's
kill-switch check runs before it reads stdin, so the upstream `printf`
in the pipe received SIGPIPE (rc 141) when the kill switch short-circuited
the read — pipefail then reported the pipeline's exit code as 141
instead of the gate's own exit 0. Fixed by reading `${PIPESTATUS[1]}`
(the gate's own exit code) instead of the pipeline's `$?` in that one
test file's `run()` helper; the other three plugins' tests never hit
this path since none of their named cases exercise the kill switch
after a full stdin write. `brand-design-guide-and-spec`'s
`record-complete` case initially failed too — a single hex color occurring
once does not satisfy "asset spec present as a second, distinct
occurrence from the brand guide entry"; fixed by adding a literal
file-path token to the test's content, which is also the more realistic
shape of a real record.

## Open findings

None — all sixteen named test cases across the four plugins pass
(`bash <plugin>/hooks/tests/methodology-gate-tests.sh` for each of the
four `brand-design-*` directories).
