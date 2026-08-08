---
subject: issue-20
role: implementation
code_under_review: HEAD
loop_state: landed
kind: coding-record
---

# Implementation record (issue-20)

## What was done

Applying the approved phase-1 proposal
(`docs/issue-20/proposals/2026-08-09-brand-design-spec-vocabulary-alignment.md`):
layering `brand-design.spec.json`'s required fields (`token_name`,
`token_type`, `value`) and `loop_state` vocabulary (`designing`,
`validating`, `landed`, `type-undeclared`, `token-file-unreachable`)
onto this rulebook's existing methodology docs and hooks, per the
proposal's "What will be done" steps 1-3.

## Why

Basis: `docs/issue-20/proposals/2026-08-09-brand-design-spec-vocabulary-alignment.md`
(approved via issue comment `APPROVE issue-20/implementation`). Issue
#20 requires the rulebook to layer the marketplace spec's vocabulary
onto existing methodology without deleting it.

## Upstream

docs/issue-20/proposals/2026-08-09-brand-design-spec-vocabulary-alignment.md

## What did not work

None.

## Doc placement

- [x] `docs/handbooks/brand-design/methodology.md` — new "Design-token
      vocabulary (spec-aligned)" subsection (handbook, per doctrine
      ladder: vocabulary/config concept).
- [x] `brand-design/hooks/directive.sh` — `PRODUCES:` asset-spec bullet
      extended with field-name parenthetical.
- [x] `brand-design-guide-and-spec/README.md` — Asset spec bullet
      extended with field-name parenthetical.

## Open findings

None.

Terminal state reached (`landed`); no next steps or resolution path
required.
