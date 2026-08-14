# brand-design methodology handbook

Worked guidance for the reasoning a regex can't check — the mechanical
half of each item below is enforced by the named `brand-design-*`
plugin's gate; this handbook exists for the judgment calls those gates
cannot make. Modeled on `pricing-rulebook/docs/handbooks/pricing/
methodology.md`'s phase split.

Norm source: `docs/issue-1/proposals/
2026-07-31-brand-design-methodology-charter.md` (adopted charter). This
handbook invents no new methodology; it explains the adopted one.

## Phase-1 proposal checklist

Owned by `brand-design-kapferer-scope-guard` (phase-1 mode).

- [ ] Does this proposal stay inside the Kapferer **Physique** (visual)
      facet? Personality, Culture, Relationship, Reflection, and
      Self-image are out of scope for this role — if the work in front
      of you touches brand voice strategy, community perception, or
      internal culture rather than the visual expression of the brand,
      that is another role's decision, not yours to make here.
- [ ] If no scoping question actually arose (the asset is unambiguously
      visual), say so explicitly rather than leaving the boundary
      unaddressed — an early exit is a valid answer, silence is not.

## Phase-2 record checklist

- [ ] **Brand guide entry** (`brand-design-guide-and-spec`): for the
      asset class touched, is every applicable sub-field (logo usage,
      color, typography, voice/tone, imagery, do's/don'ts) given a
      concrete value? For an inapplicable sub-field, did you write
      "not applicable: <reason>" instead of just omitting it?
- [ ] **Asset spec** (`brand-design-guide-and-spec`): are the values
      literal (hex/RGB, not a swatch name)? Is the *applied* value
      present, not just a restatement of the rule already given in the
      brand guide entry?
- [ ] **Consistency check** (`brand-design-wcag-consistency`): did you
      itemize pass/fail per checked item and give one consolidated
      verdict, rather than a prose paragraph that never resolves to a
      yes/no?
- [ ] **WCAG contrast** (`brand-design-wcag-consistency`): for every new
      text/background pairing, is there an actual ratio number and an
      explicit pass/fail against 4.5:1 (normal text) or 3:1 (large
      text)? "Looks fine" is not a substitute for the number.
- [ ] **Design-system source paths** (`brand-design-system-handoff`):
      did you name literal repo paths for what ux-engineering should
      pick up, rather than describing what it "should" build?
- [ ] **Prohibitions** (`brand-design-kapferer-scope-guard`, phase-2
      mode): for each of — undocumented color/font introduced silently;
      WCAG number omitted or replaced with "looks fine"; token-
      systemization work performed by this role — did you state "not
      triggered" or how it was avoided?

## Design-token vocabulary (spec-aligned)

Maps `roles/specs/brand-design.spec.json`'s required deliverable fields
and `loop_state` vocabulary onto this handbook's existing concepts —
strengthening the phase-2 checklist above, not replacing it.

- **`token_name`** maps onto the existing "asset spec" item's
  identifier half — the record must name which token the applied value
  belongs to, resolvable to an actual `design-tokens/*.json` entry
  whenever a token file is in play (the spec's `reference_resolution`
  rule; the resolution check itself is external, per
  `on-the-record/hooks/role-spec-reference-guard.sh`).
- **`token_type`** maps onto the existing "asset spec" item's format
  half, formalized to the DTCG enum — `color`, `dimension`,
  `fontFamily`, `fontWeight`, `duration`, `cubicBezier`, `number` — as
  the closed vocabulary for "asset class" when the deliverable is a
  token rather than a general visual asset.
- **`value`** maps onto the existing "asset spec" item's literal-value
  requirement verbatim — no change to that checklist language; `value`
  is simply the spec's name for what this handbook already calls "the
  applied value."
- **`loop_state`** — this rulebook's own `loop_state` words for
  `brand-design` records are, going forward, exactly the spec's five:
  `designing` and `validating` (progress), `landed` (terminal),
  `type-undeclared` (refusal), `token-file-unreachable` (error). This
  replaces informal past usage (`scope-proposed`, `open`); it does not
  create a `docs/specs/record-fields-terminal-states.json` override
  (see `docs/issue-20/proposals/
  2026-08-09-brand-design-spec-vocabulary-alignment.md`, Rationale, for
  why the gate has no supported override key for this role).

## Tool learnings (issue-1199)

Bounded fold-in from a surveyed tool-landscape sweep (adoption-evidence
method per the tech-feasibility skill; full trail in
`docs/issue-1199/reports/brand-design/scout-brief.md` on the
`on-the-record` working tree). Five entries, each borrowing a design
move, not the tool itself.

1. **diagram-design** (`github.com/cathrynlavery/diagram-design`;
   trending-repo listing at
   `trendshift.io/repositories/26141`). Problem: ad hoc diagram tooling
   (e.g. Mermaid) produces visually inconsistent, templated output for
   stakeholder-facing handoffs. How: a bounded, named list of diagram
   types, each rendered as self-contained HTML+SVG with a fixed visual
   style — no free-form category field. Upgrades: the **Design-system
   source paths** item above gains a companion requirement — name the
   diagram/asset TYPE from a fixed list (e.g. `component-map`,
   `token-flow`, `layout-grid`), not a free-form description, alongside
   the literal path.
2. **Style Dictionary** (`github.com/style-dictionary/style-dictionary`,
   an Amazon-originated build system with broad topic/dependent-package
   presence on GitHub). Problem: a token value hand-copied into each
   platform drifts from its source. How: a single source-of-truth
   token file transformed into every consuming format by one pipeline,
   never edited per-platform. Upgrades: the **Asset spec** item above
   gains a distinct sub-requirement — name the token source-of-truth
   file path (e.g. `design-tokens/color.json`), separate from the
   applied value already required.
3. **Tokens Studio for Figma** (`tokens-studio/figma-plugin`; cited
   production use at TomTom and Babbel per `docs.tokens.studio`).
   Problem: multi-brand or multi-theme token sets re-diverge when each
   theme is maintained by hand. How: a graph-structured token model
   with explicit theme composition, synced to git as JSON. Upgrades:
   the **Brand guide entry** item above gains a sub-requirement — when
   more than one brand/theme variant is touched, name which variant(s)
   explicitly, never left implicit.
4. **Stark** (`getstark.co/figma/`; vendor-stated 40,000+ users across
   28,000+ companies, and separately 230,000+ users on its Figma
   community-plugin page). Problem: an aggregate "looks fine" contrast
   review misses individual failing pairings inside a mostly-passing
   set. How: automated per-element contrast ratio and pass/fail badge,
   computed per pairing rather than once for the whole surface.
   Upgrades: the **Consistency check** item above is reworded in
   practice to require one explicit pass/fail line per distinct
   text/background pairing, not one consolidated verdict covering
   several pairings.
5. **zeroheight** (`zeroheight.com/measurement/`; multiple published
   customer case studies and its own annual Design Systems Report).
   Problem: a design-system handoff artifact can exist and still go
   unread — "driving adoption" is zeroheight's own report data's top
   recurring challenge. How: track documentation engagement and
   downstream component usage as a signal distinct from artifact
   existence. Upgrades: the **Design-system source paths** item above
   gains a sub-requirement — name which downstream role/path is
   expected to actually consume the handoff, not only where the
   artifact lives.

### Claude Code plugin/skill ecosystem (issue-1199, 2026-08-14 amendment)

Operator amendment narrowed the survey target to the Claude Code
plugin/skill ecosystem itself (marketplace/community plugins), not
general domain tools — the five entries above stay as native rules;
these three are additive, sourced from web-fetched GitHub pages this
session (full trail in
`docs/issue-1199/reports/brand-design/scout-brief.md` on the
`on-the-record` working tree).

6. **awesome-claude-design / DESIGN.md** (`github.com/VoltAgent/
   awesome-claude-design`; 3.4k GitHub stars, 375 forks). Problem: a
   brand's visual language, once agreed, gets re-derived by hand (or
   re-guessed by an AI agent) every time a downstream surface is built,
   drifting from the source decision. How: one machine-readable
   `DESIGN.md` file keeps token value, the rule that constrains it, and
   the rationale for the rule together in the same file, so an
   agent reads intent and constraint in one place rather than
   inferring intent from a token list. Upgrades: the **Brand guide
   entry** item above gains a sub-requirement — state the rationale for
   each token/rule pairing inline, not only the resolved value, so a
   downstream agent consuming the guide does not have to re-derive
   *why*.
7. **design-for-ai** (`github.com/ryanthedev/design-for-ai`; 279 GitHub
   stars). Problem: AI-generated visual design converges on generic,
   statistically-average output (uniform card grids, glassmorphism)
   because nothing pins the design decision space before generation.
   How: a "pinnable design DNA" step locks aesthetic constraints (font
   family, color hue, signature moves) *before* any candidate is
   generated, and every resulting decision must trace to a documented
   design principle rather than subjective preference. Upgrades: the
   **Consistency check** item above gains a sub-requirement — record
   which constraint (from the brand guide) each checked element traces
   to, not just its pass/fail verdict, so a failing element points back
   to the specific pinned constraint it violates.
8. **rampstackco/claude-skills brand-style-guide** (`github.com/
   rampstackco/claude-skills`; 540 GitHub stars). Problem: brand
   deliverables authored independently (identity, voice, style guide,
   archetype) drift out of sync because each is written in its own
   structure. How: every skill in the catalog shares one section order,
   tone, and authoring convention, so outputs compose without a manual
   reconciliation pass. Upgrades: the **Design-system source paths**
   item above gains a sub-requirement — new brand-design deliverables
   must reuse the existing phase-2 record's section order rather than
   introduce a new structure per deliverable, mirroring this catalog's
   uniform-structure move.

## Open decisions this handbook does not resolve

- **State-tracking**: not adopted (see `docs/issue-10/proposals/
  2026-07-31-brand-design-directive-hardening.md`, section (b),
  "State-tracking"). The charter's methodology has no cross-turn
  ordering constraint; each plugin's per-write check already enforces
  the only ordering that matters.
- **Tests location**: colocated per plugin (`brand-design-<suffix>/
  hooks/tests/methodology-gate-tests.sh`), matching this repo's existing
  convention of no repo-root `tests/` directory.
