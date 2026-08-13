---
axis: brand-identity-strategy
rule_count_floor: 3
tier: rich
---

# Brand identity strategy rules

Rules for the `decides: 브랜드 정체성이 시각적으로 일관되는가` half of
this role's contract — checking that a visual choice actually maps
back to the brand's declared identity rather than being style-work in
isolation. Grounded in Kapferer's Brand Identity Prism (this role's
own rulebook plugin is already named `brand-design-kapferer-scope-guard`,
confirming the prism as this repo's chosen framework).

## Decision rules

### 1. Require every new visual asset to trace to a stated Physique or Personality facet before shipping
- **Condition**: when a new visual direction (color, shape language, imagery style, typography mood) is proposed for a brand asset
- **Choice**: require the proposer to name which prism facet(s) — most concretely Physique (the tangible visual traits: shape, color, iconic features) or Personality (character/tone the visuals should project) — the choice is expressing, and reject a direction that cannot be tied to either facet as stated in the brand's own identity doc
- **Why**: Kapferer's model was built specifically to stop brand image (how a choice happens to look) from drifting away from brand identity (what the brand intends to stand for); a visual choice with no traceable facet is exactly the failure mode the prism was designed to catch
- **Source**: Kapferer, J-N., "Strategic Brand Management" (prism origin, 1990s); synthesis via Umbrex, "Define Brand Identity with Kapferer Brand Identity Prism", https://umbrex.com/resources/frameworks/marketing-frameworks/kapferer-brand-identity-prism/ ; Inkbot Design, "A Guide To Kapferer's Brand Identity Prism", https://inkbotdesign.com/kapferers-brand-identity-prism/
- **Counter-example test**: a proposed color shift justified only as "it looks more modern" with no reference to which prism facet "modern" is meant to serve fails this rule — "looks better" is an image judgment, not an identity-traced one.

### 2. Check the "sender" facets (Physique, Personality, Culture) and the "receiver" facets (Reflection, Self-image, Relationship) separately when auditing consistency
- **Condition**: when auditing whether a shipped asset is consistent with the brand's identity, not just internally attractive
- **Choice**: run the consistency check twice from two different questions — first, does this asset match what the brand intends to project (Physique/Personality/Culture — the sender side)? second, does this asset match how the target audience is meant to see themselves reflected and how they're meant to relate to the brand (Reflection/Self-image/Relationship — the receiver side)? A pass on only the sender side is not a full consistency check.
- **Why**: the prism's own structure splits into a sender dimension (brand communicates) and a receiver dimension (audience perceives) precisely because a brand can be internally coherent about what it wants to say while still failing to land with the audience it's for — checking only one side misses exactly the gap the model exists to expose
- **Source**: Formplus, "Understanding Kapferer's Brand Identity Prism: A Comprehensive Guide", https://www.formpl.us/blog/understanding-kapferers-brand-identity-prism-a-comprehensive-guide"
- **Counter-example test**: an asset review checklist that only asks "does this match our logo/color/tone rules" (sender-side Physique/Personality only) and has no question about target-audience self-image or relationship fails this rule — it audits only half the prism.

### 3. Drop identity facets the brand no longer actually delivers on, rather than keeping them in the guide as aspirational
- **Condition**: when a periodic identity-guide review finds a stated facet (a claimed Personality trait, a claimed Culture value) that recent shipped work and audience-facing material no longer actually expresses
- **Choice**: remove the stale facet from the active identity statement (moving it to a "retired/under consideration" note if historical continuity matters) rather than leaving it listed as current while nothing produced actually reflects it
- **Why**: an identity doc that lists facets the brand doesn't act on stops functioning as the sender-side reference the consistency check (rule 2) depends on — every subsequent audit either wrongly fails current work against a facet nobody is actually targeting, or the checker learns to silently ignore that line, which defeats the doc; the addition-only failure mode (keep old aspirational traits, bolt new ones on top) is the same subtractive-neglect pattern documented outside branding as well
- **Source**: Adams, G.S., Converse, B.A., Hales, A.H., Klotz, L.E., "People systematically overlook subtractive changes", Nature 592, 258-261 (2021), https://www.nature.com/articles/s41586-021-03380-y
- **Counter-example test**: an identity doc still listing "playful" as a core Personality trait when the last 12 months of shipped material is uniformly formal/corporate, with no update to the doc, fails this rule.
