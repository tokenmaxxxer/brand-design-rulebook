---
subject: issue-20
role: implementation
loop_state: open
---

# Current-state survey — issue-20

## Scope note (scout skip record)

Scouting per the scout-directive is skipped. Reason: the spec leaves no
external-exemplar design decision open (skip condition 2). The source
standard is already pinned and quoted verbatim inside
`roles/specs/brand-design.spec.json` (`source_standard: "DTCG Design
Tokens Format spec"`) — the three required fields (`token_name`,
`token_type` as an enum of DTCG type strings, `value`) and the
`loop_state` vocabulary are fixed by that file, not something this
proposal gets to pick among competing external options. The only open
judgment is *internal*: where each already-fixed field maps onto this
rulebook's existing methodology docs and hooks. For that internal
judgment, the closest prior art is this repo's own alignment history —
`docs/issue-2/proposals/2026-07-31-core-canon-reference-switch.md` and
`docs/issue-10/proposals/2026-07-31-brand-design-directive-hardening.md`
— both of which did the same kind of "map an externally-fixed
vocabulary onto this rulebook's existing concepts" work. That history is
the field surveyed below in place of an external sweep.

## The spec (`roles/specs/brand-design.spec.json`, read in full)

- `required_fields`: `token_name` (ref, required), `token_type` (enum:
  color / dimension / fontFamily / fontWeight / duration / cubicBezier /
  number, required), `value` (string, required).
- `reference_resolution`: `token_name` must resolve to an actual entry
  in the design-tokens JSON file — no orphan references (checked by
  `on-the-record/hooks/role-spec-reference-guard.sh`, external to this
  repo).
- `recomputation`: `value` is recomputed by re-validating `token_name`'s
  entry against the DTCG format, never asserted standalone (checker
  `TBD`, explicitly out of scope per the spec's own note).
- `write_scope`: `design-tokens/*.json`, `docs/issue-<n>/reports/
  brand-design.md`.
- `loop_state`: progress = `designing`, `validating`; terminal =
  `landed`; refusal = `type-undeclared`; error =
  `token-file-unreachable`.
- `use_when`: a new design token proposed on the branch AND no
  brand-design record exists yet for that `token_name`.

## This rulebook's current vocabulary (grep results, verbatim)

- `token_name` / `token_type` / `value` (as spec field names): **zero
  hits** anywhere in `docs/`, `README.md`, or any `brand-design*/`
  plugin file. This rulebook currently has no design-token vocabulary at
  all — its methodology is built around **assets** (logo, color,
  typography, imagery, voice/tone) and **records** (brand guide entry,
  asset spec, consistency check, WCAG contrast, design-system source
  paths), per `docs/handbooks/brand-design/methodology.md` and
  `brand-design/hooks/directive.sh`'s `PRODUCES:` line. "Asset spec"
  already carries "exact values applied (hex/RGB, not swatch name)" —
  the closest existing analogue to the spec's `value` field, but scoped
  to visual assets generally, not DTCG tokens specifically.
- `loop_state` values actually used across this repo's own records
  (`docs/issue-{1,2,5,10,13,16}/**`): `scope-proposed` (phase-1
  proposals/surveys), `open` (issue-5's phase-1 docs), `landed`
  (phase-2 terminal). No `docs/specs/record-fields-terminal-states.json`
  file exists in this repo (`find` confirmed) — the terminal-state set
  is whatever `core`'s canon gate defaults to (`landed`-only, per
  issue-2's survey, item 4) plus whatever ad hoc progress-state words
  individual records happened to use. **None of the spec's five
  words** (`designing`, `landed`, `token-file-unreachable`,
  `type-undeclared`, `validating`) appear anywhere in this repo today
  except `landed`, which already matches.
- No `design-tokens/*.json` path, no `role-spec-reference-guard.sh`,
  and no token-file-reachability concept exist anywhere in this repo.
  The four `brand-design-*` plugins' gates (`guide-and-spec`,
  `kapferer-scope-guard`, `system-handoff`, `wcag-consistency`) check
  prose-shaped record content (concrete values, itemized pass/fail,
  literal repo paths); none of them parse or reference a JSON token
  file today.

## Write-surface inventory (what phase 2 would touch)

| Surface | Current content | Spec field it would carry |
|---|---|---|
| `docs/handbooks/brand-design/methodology.md` | phase-1/phase-2 checklists, asset-class language | token_name/token_type/value as vocabulary additions to the phase-2 checklist |
| `brand-design/hooks/directive.sh` (`PRODUCES:` line) | asset-class record fields | would need a token-vocabulary line if directive.sh is judged in-scope |
| `brand-design-guide-and-spec/hooks/methodology-gate.sh` + its `README.md` | mechanically checks "asset spec" has a concrete applied value | closest mechanical analogue to `value`'s required-field check |
| loop_state usage across `docs/issue-*/reports/*.md` and any proposal frontmatter template | ad hoc words (`scope-proposed`, `open`, `landed`) | full replacement by the spec's fixed five-word set |
| `docs/specs/record-fields-terminal-states.json` | does not exist | would need creating if this rulebook adopts a role-specific terminal-state override (per core's per-repo override mechanism referenced in this session's contract reminder) |

## Prior alignment pattern (issue-2, issue-10)

Both prior "align this rulebook with an external canon" issues (issue-2:
core's stub-check canon; issue-10: methodology-gate hardening) used the
same shape: survey what the external source fixes verbatim vs. what is
still an open internal call, then a proposal that (a) maps each fixed
external element onto the nearest existing rulebook concept it
*strengthens*, (b) states plainly when an element has no natural home
rather than silently dropping it, (c) never deletes existing methodology
language, only layers onto it — consistent with this issue's own
instruction ("strengthening existing content, never deleting
methodology").
