---
subject: issue-20
role: implementation
loop_state: scope-proposed
status: proposed
files:
  - docs/handbooks/brand-design/methodology.md
  - brand-design/hooks/directive.sh
  - brand-design-guide-and-spec/README.md
  - docs/specs/record-fields-terminal-states.json
  - docs/issue-20/reports/implementation.md
---

# Proposal: align rulebook vocabulary with `brand-design.spec.json` (issue-20)

## Request

Layer the realized marketplace spec's required deliverable fields
(`token_name`, `token_type`, `value`) and `loop_state` vocabulary
(`designing`, `landed`, `token-file-unreachable`, `type-undeclared`,
`validating`) onto this rulebook's existing methodology docs and hooks —
strengthening, never deleting, what is already there. Phase 1 (this
document) maps each spec field onto an existing or new rulebook concept.

## Constraints

- Never delete existing methodology language (issue text, explicit).
- A spec field with no natural home must be stated explicitly, with
  reasoning, not silently dropped (issue's "empty state" acceptance
  criterion).
- `loop_state` vocabulary must match the spec set **exactly** — no stale
  or extra states — per the issue's second acceptance check.
- `reference_resolution` and `recomputation` are checked by
  `on-the-record/hooks/role-spec-reference-guard.sh` and a `TBD`
  follow-up checker respectively, per the spec file itself — both
  external to this repo. This rulebook layers the vocabulary and
  documents the two rules; it does not implement either checker (out of
  scope, see below).
- `write_scope` in the spec (`design-tokens/*.json`,
  `docs/issue-<n>/reports/brand-design.md`) governs the *token-file*
  role's writes when it runs in the marketplace; it is descriptive
  context for this proposal, not a write-set change for this rulebook
  repo's own files.

## Rationale

**Alternative considered and rejected: introduce a fifth
`brand-design-token-spec` plugin, parallel to the existing four
(`guide-and-spec`, `kapferer-scope-guard`, `system-handoff`,
`wcag-consistency`), to own the new vocabulary as its own mechanical
gate.** Rejected because the spec's three required fields
(`token_name`, `token_type`, `value`) describe a single DTCG token
object, not a new *facet* of brand-design methodology the way the
existing four plugins each own a distinct facet (scope, visual
guide/spec, consistency/WCAG, system handoff). `token_name`/`value` are
squarely the same concept `brand-design-guide-and-spec` already checks
under the name "asset spec" ("exact values applied — hex/RGB, not
swatch name... restating the rule instead of the applied value is a
fail"); `token_type`'s enum (color/dimension/fontFamily/fontWeight/
duration/cubicBezier/number) is a formalization of the asset classes
that plugin's own checklist ("logo usage, color, typography, imagery")
already iterates over informally. Building a parallel plugin would fork
the checklist that already exists and risk exactly the kind of
"strengthening vs. deleting" conflict the issue is written to avoid — a
second gate silently competing with the first's checks. The chosen
alternative — layering the vocabulary into the existing
`guide-and-spec` plugin's docs and checklist — keeps the mapping to
"one field, one existing home."

**`loop_state`: exact-replacement, not additive-union, chosen over
keeping the ad hoc words already in use (`scope-proposed`, `open`).**
The issue's second acceptance check is explicit: "rulebook loop_state
vocabulary matches the spec set above exactly (no stale or extra
states)". Keeping `scope-proposed`/`open` alongside the spec's five
words would leave `scope-proposed` and `open` as stale extras and fail
that check by construction. The current repo has no
`docs/specs/record-fields-terminal-states.json` override file (survey
confirmed by `find`), so this rulebook has never actually fixed its own
`loop_state` set — nothing is being taken away that was load-bearing;
`scope-proposed`/`open` were informal choices in past records, not a
documented, gate-enforced vocabulary. Phase 2 will therefore create
`docs/specs/record-fields-terminal-states.json` (`{"brand-design":
["landed"]}` as the mechanical terminal-state override, matching the
spec's `terminal: ["landed"]`) and document the full five-word
progress/terminal/refusal/error split in the methodology handbook.

## What will be done

1. **`docs/handbooks/brand-design/methodology.md`** — add a new
   subsection ("Design-token vocabulary (spec-aligned)") between the
   existing phase-1 and phase-2 checklists, stating:
   - `token_name` maps onto the existing "asset spec" item's identifier
     half — the record must name which token the applied value belongs
     to, resolvable to an actual `design-tokens/*.json` entry per the
     spec's `reference_resolution` rule (documented as a rule this
     rulebook's records must satisfy when a token file is in play; the
     resolution check itself stays external, per Constraints).
   - `token_type` maps onto the existing "asset spec" item's format
     half, formalized to the DTCG enum (color, dimension, fontFamily,
     fontWeight, duration, cubicBezier, number) as the closed vocabulary
     for what "asset class" now means when the deliverable is a token
     rather than a general visual asset.
   - `value` maps onto the existing "asset spec" item's literal-value
     requirement verbatim — no change to that existing checklist
     language, only a note that `value` is the spec's name for what this
     handbook already calls "the applied value."
   - `loop_state` vocabulary: document the full spec set (`designing`,
     `validating` as progress; `landed` as terminal;
     `type-undeclared` as refusal; `token-file-unreachable` as error)
     as this rulebook's own `loop_state` words for `brand-design`
     records going forward, replacing informal past usage.
2. **`brand-design/hooks/directive.sh`** — extend the existing
   `PRODUCES:` line's "asset spec" bullet with the `token_name` /
   `token_type` / `value` field names (parenthetical, not a rewrite),
   so the mechanical/quoted directive text carries the same vocabulary
   the handbook now documents. No other line of `directive.sh` changes.
3. **`brand-design-guide-and-spec/README.md`** — add the same
   parenthetical field-name mapping to its existing "Asset spec"
   bullet, so the plugin's own README (read by anyone installing it in
   isolation) is not left silently behind the handbook.
4. **`docs/specs/record-fields-terminal-states.json`** (new file) —
   `{"brand-design": ["landed"]}`, matching the spec's
   `terminal: ["landed"]` exactly, per the repo-override mechanism this
   session's own contract reminder documents.
5. **`docs/issue-20/reports/implementation.md`** — phase-2 record, per
   contract v3 s19, written only after approval opens phase 2.

## Out of scope

- Implementing `role-spec-reference-guard.sh` or the `TBD` recomputation
  checker — both are named in the spec as checked by
  on-the-record-side or not-yet-built tooling, external to this repo.
- A fifth `brand-design-token-spec` plugin (see Rationale) — the
  mapping lands inside the existing `guide-and-spec` plugin's docs
  instead.
- Any change to `brand-design-kapferer-scope-guard`, `-system-handoff`,
  or `-wcag-consistency` — none of their existing checks (scope facet,
  design-system paths, WCAG contrast) map onto any of the three spec
  fields or the loop_state vocabulary; the four-plugin split (Rationale,
  `docs/issue-10/proposals/2026-07-31-brand-design-directive-hardening.md`)
  is preserved unchanged.
- Any gate/hook *behavior* change (`methodology-gate.sh` logic) — this
  proposal is a vocabulary/documentation layer; making a gate
  mechanically require `token_name`/`token_type`/`value` presence is a
  follow-up if a future issue asks for it, not implied by this one.
- `design-tokens/*.json` write-scope handling — this repo does not
  currently produce or consume that file; nothing here creates it.

## How you'll know it worked

- `grep -ri token_name docs/ README.md`, `grep -ri token_type docs/
  README.md`, `grep -ri "value" docs/handbooks/brand-design/
  methodology.md` each return at least one hit after phase 2 (issue's
  first acceptance check).
- `grep -rn "loop_state" docs/handbooks/brand-design/methodology.md`
  shows exactly the five spec words documented, and no other
  `loop_state` word remains prescribed as this rulebook's own vocabulary
  going forward (issue's second acceptance check — checked by reading
  the handbook section added in step 1, since no automated `loop_state`
  vocabulary-set gate exists in this repo).
- `pytest` / `tests/*.sh`: this repo has no root `tests/` directory and
  no `pytest` config (survey confirmed); each `brand-design-*` plugin's
  own `hooks/tests/methodology-gate-tests.sh` is unaffected by this
  proposal (no gate logic changes) and is not rerun as part of this
  work. State per the issue's own third acceptance check: `unverifiable:
  no repo-root test suite present`.
