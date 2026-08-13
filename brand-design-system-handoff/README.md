# brand-design-system-handoff

Owns one methodology concern for the `brand-design` role (contract v3,
issue-10 maturation round): **design-system source paths + the
Atomic-Design `HAND_OFF → ux-engineering` boundary discipline**, drawn
from the adopted charter (`docs/issue-1/proposals/
2026-07-31-brand-design-methodology-charter.md`, component 4).

## What it enforces

A `PreToolUse` gate on `docs/issue-<n>/reports/brand-design.md` denies
the write unless it names at least one literal repo path (e.g.
`ux-engineering/tokens/color.json`) for the design-system sources
touched or handed off — a description of what ux-engineering "should"
build is not a substitute.

The `HAND_OFF` discipline itself ("stop and hand off, do not silently
absorb another role's scope, record the hand-off point before opening
the next role's session") is authored into the base `brand-design`
plugin's `directive.sh` — this plugin's gate is the mechanical half of
the same concern.

Fail-closed on internal error, unparseable payload, or undeterminable
resulting content. Writes outside the phase-2 record path exit 0
immediately.

## Install

Registered in `.claude-plugin/marketplace.json` alongside the base
`brand-design` plugin and its sibling `brand-design-*` plugins. Not
independently useful.

## Kill switch

```
export BRAND_DESIGN_SYSTEM_HANDOFF_GATE_OFF=1
```

## Tests

```
bash hooks/tests/methodology-gate-tests.sh
```

See also `docs/handbooks/brand-design/methodology.md`'s "Tool learnings
(issue-1199)" section for the diagram/asset-type-enum and
downstream-consumer sub-requirements this gate's path check rests on.

## Relationship to core canon

Additive on top of core's generic `record-fields-gate.sh` (§20 fields),
never a replacement. Gate-construction pattern modeled on
`pricing-rulebook`'s `pricing/hooks/methodology-gate.sh` — referenced,
not copied.
