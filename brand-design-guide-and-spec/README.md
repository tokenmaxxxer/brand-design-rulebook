# brand-design-guide-and-spec

Owns one methodology concern for the `brand-design` role (contract v3,
issue-10 maturation round): **brand guide entry + asset spec
presence/cross-reference**, drawn from the adopted charter
(`docs/issue-1/proposals/2026-07-31-brand-design-methodology-charter.md`,
components 1-2).

## What it enforces

A `PreToolUse` gate on `docs/issue-<n>/reports/brand-design.md` (the
phase-2 record only — phase-1 proposals are
`brand-design-kapferer-scope-guard`'s business) denies the write unless
the resulting content carries:

1. **Brand guide entry** — a concrete per-sub-field value (logo usage
   rule, color hex/rgb, typography role, voice/tone note, imagery style,
   do's/don'ts), or an explicit `not applicable: <reason>` for a
   sub-field that does not apply.
2. **Asset spec** — the literal applied value (color/hex or a
   file-format/path token) appearing a second, distinct time from the
   brand guide entry's rule statement — restating the rule instead of
   the applied value is a fail. (Spec-aligned field names:
   `token_name`, `token_type`, `value` — see
   `docs/handbooks/brand-design/methodology.md`.)

Fail-closed: any internal error, unparseable payload, or
undeterminable resulting content denies the write. Writes outside the
phase-2 record path exit 0 immediately.

## Install

Registered in `.claude-plugin/marketplace.json` alongside the base
`brand-design` plugin and its sibling `brand-design-*` plugins. Not
independently useful — requires the base `brand-design` plugin's
`SessionStart` directive and `write_scope`.

## Kill switch

```
export BRAND_DESIGN_GUIDE_AND_SPEC_GATE_OFF=1
```

## Tests

```
bash hooks/tests/methodology-gate-tests.sh
```

See also `docs/handbooks/brand-design/methodology.md`'s "Tool learnings
(issue-1199)" section for the token-source-of-truth-path and
multi-brand-variant sub-requirements this gate's checklist items rest on.

## Relationship to core canon

Additive on top of core's generic `record-fields-gate.sh` (§20 fields),
never a replacement. Gate-construction pattern modeled on
`pricing-rulebook`'s `pricing/hooks/methodology-gate.sh` — referenced,
not copied.
