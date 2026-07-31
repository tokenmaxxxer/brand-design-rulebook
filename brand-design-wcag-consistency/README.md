# brand-design-wcag-consistency

Owns one methodology concern for the `brand-design` role (contract v3,
issue-10 maturation round): **consistency check vs. existing guide +
WCAG contrast gate**, drawn from the adopted charter
(`docs/issue-1/proposals/2026-07-31-brand-design-methodology-charter.md`,
component 3).

## What it enforces

A `PreToolUse` gate on `docs/issue-<n>/reports/brand-design.md` denies
the write unless:

- when a new text/background color pairing is mentioned: a named
  per-item pass/fail consistency check AND a WCAG ratio number (e.g.
  `4.6:1`) with an explicit pass/fail against 4.5:1 (normal) / 3:1
  (large) — "looks fine" or a bare number with no verdict is a fail;
- when no new pairing is introduced: an explicit early-exit statement
  ("no new text/background pairing introduced").

Fail-closed on internal error, unparseable payload, or undeterminable
resulting content. Writes outside the phase-2 record path exit 0
immediately.

## Install

Registered in `.claude-plugin/marketplace.json` alongside the base
`brand-design` plugin and its sibling `brand-design-*` plugins. Not
independently useful.

## Kill switch

```
export BRAND_DESIGN_WCAG_CONSISTENCY_GATE_OFF=1
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
