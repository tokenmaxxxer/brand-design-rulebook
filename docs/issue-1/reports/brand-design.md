---
subject: issue-1
role: brand-design
loop_state: landed
---

# Record — methodology charter reflection into the plugin (issue-1)

## What was done

Reflected the approved methodology charter
(`docs/issue-1/proposals/2026-07-31-brand-design-methodology-charter.md`)
into `brand-design/hooks/directive.sh`'s `PRODUCES` line. The string was
expanded from an unstructured noun list to name the required sub-fields
for each of the four `PRODUCES` nouns, per the charter's "Required
components, per deliverable" section:

- **brand guide entry** — logo usage rule (if a logo is involved),
  exact color values (hex/RGB), typography role, voice/tone note (if
  copy is present), imagery style note (if applicable), do's/don'ts.
- **asset spec** — exact values applied (not restated rules) + file
  formats/paths produced.
- **consistency check vs existing guide** — checklist pass/fail,
  including the WCAG contrast result (4.5:1 AA normal text / 3:1 AA
  large text) as an actual recorded number.
- **design-system source paths** — unchanged from the charter (literal
  paths handed to ux-engineering; brand-design states the rule, does not
  build the token system).

The `core_role_directive "$YOU_DECIDE" "$USE_WHEN" "$PRODUCES"
"$HAND_OFF"` call shape is untouched — only the `PRODUCES` string's
content changed, matching the charter's constraint that this stays
inside core canon's existing 4-argument shape. `hooks.json` was not
touched (no change to which hooks fire, per the charter's plan item 3).
`warrant-hunter`/gates remain referenced from core canon only; nothing
under `brand-design/` vendors a copy of any core script.

## Why

Basis: the approved phase-1 charter's "Required components, per
deliverable" and "Plugin reflection plan" sections, backed by
`docs/issue-1/reports/brand-design/scout-brief.md`. The charter argues
the `YOU_DECIDE` mandate ("브랜드 정체성이 시각적으로 일관되는가") is
unverifiable without a paper trail of what was decided (brand guide
entry + asset spec) and a named checklist producing pass/fail
(consistency check w/ WCAG gate); expanding `PRODUCES` to name those
sub-fields is the mechanical step that makes future brand-design records
checkable against a concrete shape instead of an unstructured noun list.

## Upstream basis

`docs/issue-1/proposals/2026-07-31-brand-design-methodology-charter.md`
(sections "Phase-2 deliverable norm" and "Plugin reflection plan, item
1"), itself built on
`docs/issue-1/reports/brand-design/scout-brief.md`. Approval: issue-1
comment `APPROVE issue-1/brand-design` posted by `JiwonJung94`, an
`approvers.md` account, in single-account mode (PR #8 author and the
approver are the same account, per contract v3 s19).

## What was intentionally not done (per charter's out-of-scope + open item)

- No gate script was added or modified. The charter's plugin-reflection
  plan item 2 leaves an explicit open sub-decision for a future approver:
  whether core's generic record-fields-gate (what/why/upstream-basis/
  loop_state/open-findings — the same fixed shape this very record is
  gated against) is sufficient, or whether a role-specific
  substring/structure check (e.g. enforcing a WCAG pass/fail number or a
  logo clear-space rule inside a future `docs/issue-<n>/reports/
  brand-design.md`) should be proposed to core or added locally. This
  delivery does not pre-decide it, per the charter's own scope line.
- No change to `warrant-hunter` or any core-canon-referenced gate.
- `docs/handbooks/` was not created; the charter names the
  required-components list as candidate content for a future handbook
  entry if this repo grows one, not a mandate to create it now.

## Verification

- `brand-design/hooks/directive.sh` still defines exactly one
  `core_role_directive` call with four arguments (unchanged shape) —
  confirmed by inspection; only the `PRODUCES` variable's string content
  changed.
- Diff is scoped to the `PRODUCES` line only; `hooks.json` and
  `.claude-plugin/plugin.json` are untouched.

## Open findings

The role-specific-gate-vs-generic-gate sub-decision named in the
charter's plugin reflection plan item 2 (core's generic record-fields
check vs a role-specific substring check) remains open, carried forward
as a deliberately deferred approver-visible choice — not a defect in
this delivery, and not blocking issue-1's own closure since the charter
explicitly flagged it rather than resolved it.
