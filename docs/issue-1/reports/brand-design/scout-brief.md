# Scout brief — issue-1 (brand-design domain methodology survey)

Live web search was used for this survey (not memory-only). Findings below
are the load-bearing points extracted from real, well-known sources; full
URLs are listed at the end.

## Must-bes (patterns nearly every real source agrees are non-negotiable)

- A brand style guide/brand book must specify **logo usage as rules, not
  just images**: every approved variant (primary/secondary/monochrome/
  reversed), minimum size, clear-space, and forbidden manipulations.
- **Color must be specified in exact, reproducible values** (hex/RGB/CMYK/
  Pantone), not swatches alone — this is what makes a color spec
  machine- and print-portable across teams.
- **Typography must be a system** (family, weight, size/spacing per role:
  heading/body/caption), not a single "our font is X" statement.
- **Voice/tone and imagery style are named as first-class sections**
  alongside visual rules — brand guides are explicit that consistency is
  as much verbal/behavioral as visual.
- **Do's/don'ts are a required, distinct section** in nearly every modern
  guide — the misuse cases (off-brand color mixing, logo distortion,
  wrong tone by channel) are documented, not left implicit.
- Every element in a design system (Atomic Design: atoms → molecules →
  organisms → templates → pages, Brad Frost) is defined **once** and
  composed everywhere else — the methodological reason token systems and
  brand guides pair well: a brand guide states the *rule*, a design
  system encodes the *reusable unit* that obeys the rule.
- **Accessibility is now a required, testable constraint** on brand color
  choices: WCAG 2 requires ≥4.5:1 contrast for normal text (≥3:1 for large
  text) at AA, ≥7:1 at AAA — meaning a brand's primary color palette must
  be checked against contrast math, not just aesthetic judgment, before
  it is declared usable for text.
- Kapferer's Brand Identity Prism (six facets: Physique, Personality,
  Culture, Relationship, Reflection, Self-image) is the standard academic
  frame for stating *why* a visual rule exists — it separates "what the
  brand looks like" (Physique — the only facet brand-design visual work
  directly controls) from the other five facets that live in strategy/
  marketing, which is useful for scoping what this role should and should
  not decide.

## Performance axes (what "good" is measured against)

- **Reproducibility**: can two different people/tools independently
  produce the same asset from the spec alone (exact color values, not
  "looks about right")?
- **Coverage**: does the guide address every asset class actually in
  use (digital + print + motion), not just the primary logo lockup?
- **Contrast/accessibility pass rate**: percentage of brand-color/text
  pairings that clear WCAG AA.
- **Consistency-check-ability**: can a new asset be checked against the
  existing guide by inspection (a literal audit step), not just "feels
  on-brand"?

## Adopt

- Brand guide required sections: logo rules, exact color values,
  typography system, voice/tone, imagery style, do's/don'ts,
  accessibility/contrast requirement — this maps directly onto
  `directive.sh`'s `PRODUCES` line (brand guide entry, asset spec,
  consistency check) and gives it concrete required components instead
  of a vague noun.
- Atomic Design's "define once, compose everywhere" principle as the
  justification for the existing `HAND_OFF → ux-engineering` line: brand
  guide rules are the *source of truth*, ux-engineering's token
  systemization is the *reusable unit* — this is exactly the atoms/brand
  distinction, so the existing hand-off boundary is validated by real
  methodology, not arbitrary.
- WCAG contrast thresholds as an explicit, testable requirement inside
  the "consistency check vs existing guide" produces-field — turns a soft
  design-review step into a checkable pass/fail.
- Kapferer's Physique facet as the explicit scope boundary for this role
  (visual expression only) — the other five facets are out of this
  role's `YOU_DECIDE` mandate ("시각적으로 일관되는가"), which the prism
  makes explicit rather than assumed.
- A lightweight heuristic-evaluation-style audit format (Nielsen-lineage:
  named checklist, per-item pass/fail, severity, consolidated report) for
  the "consistency check vs existing guide" deliverable — cheap, doesn't
  require a user study, matches this role's static-artifact nature.

## Skip

- Full academic Brand Identity Prism as a *required deliverable
  component* — its other five facets (Personality, Culture, Relationship,
  Reflection, Self-image) are strategy/positioning work outside this
  role's visual-consistency mandate; adopting it as a *scoping lens* only
  (see Adopt), not a template every asset spec must fill out.
- Full Nielsen 10-heuristic usability evaluation apparatus (multi-
  evaluator recruiting, severity-rating panels) — built for interactive
  UI usability, heavier than a static brand-consistency check needs;
  adopt only the checklist/consolidated-report *shape*, not the
  multi-rater process.
- Full corporate identity manual scope (naming conventions, legal/
  trademark usage, packaging engineering specs) — real brand books
  include these, but they exceed what a single `brand-design` role in
  this multi-role contract is asked to decide (`USE_WHEN: 브랜드 자산
  신설/변경`); other roles or a later expansion would own those if ever
  needed.

## Gap

No source surveyed gives a ready-made "proposal document" format for an
AI-agent contract system — brand methodology sources describe finished
guide artifacts (phase-2 shape), not how to propose one before building it
(phase-1 shape). The phase-1 proposal-doc norm in the accompanying
proposal is therefore derived by combining this repo's own existing
proposal convention (docs/issue-2, docs/issue-5) with the phase-2 content
norms surveyed here, not lifted from an external source — flagged so this
gap isn't silently presented as "found in research."

## Sources

- [What Is a Style Guide? 2026 Guide with Brand UX Examples](https://www.parallelhq.com/blog/what-style-guide)
- [How to create a brand style guide in 2026](https://www.prezent.ai/blog/brand-style-guide)
- [Brand Guidelines & Style Guide: Complete Creation Guide — Spellbrand](https://spellbrand.com/blog/brand-guidelines-style-guide-creation)
- [The Ultimate Guide to Creating Brand Guidelines (2026)](https://thebrandstrategylab.com/blog/ultimate-guide-to-creating-brand-guidelines/)
- [How To Create Brand Style Guidelines in 2026 — Venngage](https://venngage.com/blog/brand-style-guide/)
- [What are Brand Guidelines? — IxDF](https://ixdf.org/literature/topics/brand-guidelines)
- [Atomic Design Methodology — Brad Frost](https://atomicdesign.bradfrost.com/chapter-2/)
- [Brad Frost's Atomic Design: build systems, not pages — designsystems.com](https://www.designsystems.com/brad-frosts-atomic-design-build-systems-not-pages/)
- [Understanding Kapferer's Brand Identity Prism](https://www.formpl.us/blog/understanding-kapferers-brand-identity-prism-a-comprehensive-guide)
- [Define Brand Identity with Kapferer Brand Identity Prism — Umbrex](https://umbrex.com/resources/frameworks/marketing-frameworks/kapferer-brand-identity-prism/)
- [A Guide To Kapferer's Brand Identity Prism — Inkbot Design](https://inkbotdesign.com/kapferers-brand-identity-prism/)
- [Color Contrast for Accessibility: WCAG Guide (2026)](https://www.webability.io/blog/color-contrast-for-accessibility)
- [What Is the WCAG 4.5:1 Contrast Ratio — TestParty](https://testparty.ai/blog/wcag-contrast-ratio-guide-2025)
- [How to do the Heuristic Evaluation/UX Audit — Medium](https://medium.com/design-bootcamp/how-to-do-the-heuristic-evaluation-ux-audit-622085a990a5)
- [Nielsen's Heuristics — The Decision Lab](https://thedecisionlab.com/reference-guide/design/nielsens-heuristics)
