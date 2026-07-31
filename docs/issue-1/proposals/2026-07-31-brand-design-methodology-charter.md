---
subject: issue-1
role: brand-design
loop_state: scope-proposed
---

# Proposal: brand-design methodology charter (issue-1)

## Request (paraphrased intent)

This rulebook's `brand-design/hooks/directive.sh` currently states its
mandate (`YOU DECIDE: 브랜드 정체성이 시각적으로 일관되는가`) and a
`PRODUCES` line (brand guide entry, asset spec, consistency check,
design-system source paths) but neither is grounded in any surveyed
domain methodology — they were written by guesswork when the skeleton was
seeded. Issue #1 asks for two things, in phase 1 only: (1) broadly survey
real, well-known brand-design methodology and deliverable norms
(textbook/industry-standard/representative-practice level), and (2)
propose which norms this rulebook should adopt for (a) its own phase-1
proposal documents and (b) this role's phase-2 deliverables, each
justified against the `YOU_DECIDE` mandate, plus (d) a plugin-reflection
plan describing — not executing — what would change in `directive.sh`'s
`PRODUCES` line and any future gate. See
`docs/issue-1/reports/brand-design/scout-brief.md` for the full survey
this proposal is built on.

## Constraints

- Phase-1 only — no file is created, deleted, or edited outside
  `docs/issue-1/**` in this PR. Phase 2 (reflecting the approved charter
  into `directive.sh`/`hooks.json`) executes only after Approve, per
  contract v3 s19.
- warrant-hunter is referenced from core canon in this repo already
  (issue-2/issue-5); this proposal does not touch `agents/` or any gate
  script and does not reintroduce a vendored copy of anything.
- Live web search was available and used (see scout-brief.md's Sources
  list); no methodology claim below is fabricated — anything not
  externally sourced is flagged as such in the brief's Gap note.

## Phase-1 proposal-doc norm (this rulebook's own future proposals)

**Adopted methodology:** keep this repo's existing proposal shape
(established by `docs/issue-2/proposals/...` and
`docs/issue-5/proposals/...`) as the fixed format for all future
`brand-design` phase-1 proposals — frontmatter (`subject`/`role`/
`loop_state`) + Request/Constraints/body/Out-of-scope/Judged-by sections.

**Required sections for a brand-design phase-1 proposal, going forward:**

1. Frontmatter: `subject: issue-<n>`, `role: brand-design`,
   `loop_state: scope-proposed` (or `open` if scouting is skipped —
   mirrors the issue-5 precedent).
2. Request (paraphrased intent) — restates the ask, cites the file(s)
   that motivate it (e.g. an outdated `directive.sh` line).
3. Constraints.
4. The adopted-norm sections themselves (methodology + justification).
5. What is out of scope.
6. How this will be judged — must resolve to checkable facts (a file
   exists / a value matches / a script exits 0), not subjective review.

**Evidence/citation format:** every adopted external methodology claim
must carry either (a) a real URL in an accompanying `reports/.../
scout-brief.md`-style survey doc, in the same findings-only shape as
`docs/issue-2/reports/implementation/survey.md` (adapted here to
`scout-brief.md` per this role's scouting convention: must-bes,
performance axes, adopt/skip, gap line, Sources list), or (b) an explicit
"no live search available, using established prior knowledge" flag if web
tools are unavailable that run — never an unflagged, unsourced claim
presented as researched fact.

**Why this fits the mandate:** the `YOU_DECIDE` question is about visual
*consistency*, which is unverifiable without a paper trail of what was
decided and why. A proposal format that forces citation and a fixed
judged-by section is the phase-1 analogue of the "consistency check vs
existing guide" this role must produce in phase 2 — the rulebook's own
proposal process should model the same rigor it will demand of this
role's deliverables.

## Phase-2 deliverable norm (brand-design's future produces)

**Adopted methodology:** a brand-guide-first hierarchy modeled on
real brand style guide structure (logo/color/typography/voice/imagery/
do's-don'ts) crossed with Atomic Design's "define once, compose
everywhere" principle for the design-system hand-off boundary, plus a
WCAG-based accessibility gate on color, plus a lightweight heuristic-
checklist format for the consistency check. Kapferer's Brand Identity
Prism is adopted only as a *scoping lens* (Physique facet = this role's
domain; the other five facets are out of scope), not as a deliverable
template.

**Required components, per deliverable (maps 1:1 onto the four
`PRODUCES` nouns already in `directive.sh`):**

- **Brand guide entry** — must state, for the asset class touched: logo
  usage rule (variant/min-size/clear-space/forbidden-manipulation, if a
  logo is involved), exact color values (hex/RGB, not swatch-only),
  typography role (heading/body/caption assignment), voice/tone note (if
  the asset carries copy), imagery style note (if photographic/
  illustrative), and an explicit do's/don'ts line.
- **Asset spec** — the reproducible technical spec for the new/changed
  asset itself: exact values used from the brand guide entry above (not
  restated rules, the literal values applied), file formats/paths
  produced.
- **Consistency check vs existing guide** — a short checklist-style
  audit (Nielsen-lineage shape: named checklist items, pass/fail per
  item, one consolidated verdict), covering: (i) does every value in the
  asset spec trace to an entry already in the brand guide (no
  undocumented new color/font introduced silently), and (ii) WCAG
  contrast check — any text/background color pairing introduced must be
  reported against the 4.5:1 (AA, normal text) / 3:1 (AA, large text)
  thresholds, with the actual pass/fail number recorded, not "looks
  fine."
- **Design-system source paths** — literal file paths of the
  machine-usable form (tokens/components) that ux-engineering will
  systemize on hand-off; this is the Atomic Design boundary: brand-design
  states the rule and points at its source location, ux-engineering
  turns it into a reusable atom/token — brand-design does not itself
  build the token system.

## Justification tied to `YOU_DECIDE`

The mandate is "브랜드 정체성이 시각적으로 일관되는가" — visual
consistency is checkable only if (a) prior decisions are recorded in a
fixed-shape guide entry (so "existing guide" in the consistency check has
literal content to compare against, not tribal memory), and (b) the
comparison step itself is a named checklist producing a pass/fail, not a
subjective sign-off. Every adopted component above exists to make one of
those two things true:

- Brand guide entry + asset spec → gives future consistency checks
  something concrete to check against (reproducibility axis from the
  survey).
- Consistency check w/ WCAG gate → turns "is it consistent" into a
  checkable fact, matching how this repo already prefers gates that
  "resolve to yes/no backed by a pointable artifact" (the same principle
  issue-2/issue-5's judged-by sections already use).
- Design-system source paths + Atomic-Design-justified hand-off boundary
  → keeps this role scoped to *stating* the rule, not implementing token
  systemization, matching the existing `HAND_OFF → ux-engineering` line
  instead of duplicating ux-engineering's job.
- Kapferer's Physique-only scoping → keeps this role from silently
  expanding into brand strategy/positioning (Personality, Culture,
  Relationship, Reflection, Self-image), which the mandate's own wording
  ("시각적으로") already excludes; the prism just makes that exclusion
  explicit and citable.

## Plugin reflection plan (phase 2, described only — not implemented here)

This section is a plan for what phase 2 would change; no hook, gate, or
plugin file is touched by this proposal.

1. **`brand-design/hooks/directive.sh` — `PRODUCES` line.** Expand from
   the current unstructured noun list to name the required sub-fields
   above, e.g.:

       PRODUCES (required record fields): brand guide entry (logo/color/
       typography/voice/imagery/do's-don'ts as applicable), asset spec
       (exact values + paths), consistency check vs existing guide
       (checklist pass/fail incl. WCAG contrast result), design-system
       source paths

   This stays inside `core_role_directive`'s existing 4-argument shape
   (per the issue-2 survey's finding that the canon function takes
   exactly `you_decide`/`use_when`/`produces`/`hand_off`) — only the
   `produces` string's *content* changes, not the call shape.

2. **A future `record-fields-gate`-equivalent (if core's generic §20
   gate is judged insufficient for this role).** Per the issue-2 survey,
   core's canon `record-fields-gate.sh` checks a fixed generic field set
   (what/why/upstream-basis/loop_state/open-findings), not this role's
   specific produces-vocabulary — so today, nothing gate-enforces that a
   `brand-design.md` record actually contains a WCAG pass/fail number or
   a logo clear-space rule; it only enforces the generic shape. Phase 2
   should decide, as an explicit approver-visible choice (not silently):
   (a) accept that gap, matching issue-2's precedent of deferring to
   core's consolidation decision, or (b) propose a role-specific
   substring/structure check to core or as a local addition. This
   proposal does not pre-decide (a) vs (b) — it flags the choice for the
   approver, since core's issue-66 report already stated role-specific
   vocabulary checks were deliberately dropped in favor of the generic
   gate.
3. **No change to `hooks.json`** is anticipated — this charter changes
   the *content* of what `directive.sh` renders and what a future record
   must contain, not which hooks fire.
4. **`docs/handbooks/`** (if this repo grows one, per the issue-2
   proposal's precedent of moving boilerplate-shaped standing guidance
   there): the required-components list in this charter's "Phase-2
   deliverable norm" section is the candidate content for a future
   `brand-design` handbook entry, so it does not have to be re-derived
   per asset.

## What is out of scope

- Actually editing `brand-design/hooks/directive.sh`, `hooks.json`, or
  any gate script — phase 2 only, after Approve.
- Writing `docs/issue-1/reports/brand-design.md` (the phase-2 record
  file) — off limits this phase.
- Deciding option (a) vs (b) in the plugin-reflection plan's item 2 —
  flagged for the approver, not resolved here.
- Any change to `warrant-hunter` or core-canon-referenced gates (out of
  this issue's scope per the issue's own constraint).
- Full corporate-identity-manual scope (naming/trademark/packaging) —
  per scout-brief.md's Skip list, exceeds this role's `USE_WHEN` trigger.

## How this will be judged

- `docs/issue-1/reports/brand-design/scout-brief.md` exists, contains a
  non-empty `Sources:` list of real URLs, and states must-bes/performance
  axes/adopt/skip/gap per this repo's scouting convention.
- This proposal file exists at
  `docs/issue-1/proposals/2026-07-31-brand-design-methodology-charter.md`
  with frontmatter `subject: issue-1`, `role: brand-design`,
  `loop_state: scope-proposed`.
- Every adopted norm in the two sections above is traceable to a cited
  source in scout-brief.md or explicitly flagged as prior-knowledge, not
  asserted bare.
- No file outside `docs/issue-1/**` is modified by this PR.
- The plugin reflection plan names the exact `directive.sh` line it would
  change and leaves the one open sub-decision (role-specific gate or not)
  explicit for the approver rather than silently resolved.
