# brand-design-kapferer-scope-guard

Owns one methodology concern for the `brand-design` role (contract v3,
issue-10 maturation round), phase-aware: **Kapferer Physique-facet
scope acknowledgement (phase-1)** and **prohibitions acknowledgement
(phase-2)**, drawn from the adopted charter (`docs/issue-1/proposals/
2026-07-31-brand-design-methodology-charter.md`, "Justification tied to
YOU_DECIDE"). The only one of the four `brand-design-*` plugins active
on both write surfaces.

## What it enforces

A `PreToolUse` gate that branches by which write-surface matched:

- **Phase-1** (`docs/issue-<n>/proposals/*brand-design*.md`): the
  proposal must name the Physique-facet-only scope boundary (Kapferer's
  Personality/Culture/Relationship/Reflection/Self-image facets are out
  of scope), or state an explicit early exit ("no scoping question
  arose").
- **Phase-2** (`docs/issue-<n>/reports/brand-design.md`): the record
  must name each of the charter's prohibitions as either "not
  triggered" or how it was avoided (no undocumented color/font
  introduced silently; no WCAG number omitted or replaced with "looks
  fine"; no token-systemization work performed by this role).

Fail-closed on internal error, unparseable payload, or undeterminable
resulting content. Writes outside both surfaces exit 0 immediately.

## Install

Registered in `.claude-plugin/marketplace.json` alongside the base
`brand-design` plugin and its sibling `brand-design-*` plugins. Not
independently useful.

## Kill switch

```
export BRAND_DESIGN_KAPFERER_SCOPE_GUARD_GATE_OFF=1
```

## Tests

```
bash hooks/tests/methodology-gate-tests.sh
```

## Relationship to core canon

Additive on top of core's generic `record-fields-gate.sh` (§20 fields),
never a replacement. Gate-construction pattern modeled on
`pricing-rulebook`'s `pricing/hooks/methodology-gate.sh` — referenced,
not copied.
