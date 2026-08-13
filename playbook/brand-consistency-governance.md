---
axis: brand-consistency-governance
rule_count_floor: 3
tier: rich
---

# Brand consistency / asset governance rules

Rules for the `produces: ... consistency check vs existing guide` half
of this role's contract — how a new/changed asset is checked against
the standing brand system, and how the system itself stays governable
rather than drifting.

## Decision rules

### 1. Lock core identity elements (logo, primary color, primary type) in the template layer; leave only content zones editable
- **Condition**: when producing a template or asset-generation surface that non-design teams will use to create brand-facing material without a designer in the loop
- **Choice**: fix logo placement/size, primary palette, and primary typeface at the template level so an editor cannot alter them; expose only body copy, imagery, and explicitly-marked approved variant zones as editable
- **Why**: over-permissioning core brand elements is the most commonly cited practitioner failure mode in brand governance — broken templates and inconsistent output trace back to editors having write access to elements that should have been fixed, not to editors making bad content choices in zones meant to vary
- **Source**: Bynder, "Turning brand governance into a competitive advantage", https://www.bynder.com/en/blog/what-is-brand-governance/ ; Marq, "2026 Brand Governance: Framework & How to Implement It At Scale", https://www.marq.com/blog/brand-governance/
- **Counter-example test**: a slide-deck template that allows any user to resize/recolor the logo lockup "for flexibility" fails this rule, even if every other governance control (approval workflow, asset expiry) is in place.

### 2. Route review effort by risk, not uniformly — low-risk internal assets skip sign-off, high-risk public/campaign assets require brand-manager approval
- **Condition**: when defining the approval workflow an asset must pass through before it ships
- **Choice**: classify asset types into at least two review tiers (e.g. internal/low-risk = no gate or self-check only; external/campaign/high-visibility = mandatory brand-manager sign-off) rather than requiring every asset to pass the same review gate
- **Why**: a single uniform gate either bottlenecks low-risk internal work (teams route around it, defeating the gate) or under-scrutinizes high-risk public-facing work if the gate is set light enough to not bottleneck internal use — risk-tiered review is the practitioner-documented resolution
- **Source**: Bynder, "What Is brand compliance? How to stay on brand with DAM", https://www.bynder.com/en/blog/what-is-brand-compliance/ ; Marq, "Brand Asset Management Guide", https://www.marq.com/blog/brand-asset-management/
- **Counter-example test**: a governance doc requiring every asset, including an internal Slack graphic, to get the same brand-manager sign-off as a public campaign launch fails this rule — uniform gating at the strictest tier is not risk-routed.

### 3. Expire and remove outdated/unapproved assets from the shared library instead of leaving them alongside current ones
- **Condition**: when a brand asset library accumulates versions of a logo, template, or guideline document across rebrands, campaign cycles, or guide revisions
- **Choice**: set and enforce an expiration/removal policy that actually deletes or hard-archives (outside the searchable/default library view) assets superseded by a newer approved version, rather than leaving old and new versions co-located and equally discoverable
- **Why**: version/expiration control over the asset lifecycle is named directly by governance practitioners as the mechanism that prevents outdated or unapproved content from making it to market — the risk is not that the new asset is wrong, it's that the old one is still findable and gets picked by mistake
- **Source**: Marq, "Brand Asset Management Guide: Best Practices & Solutions for Growing Teams", https://www.marq.com/blog/brand-asset-management/
- **Counter-example test**: a shared drive where the 2022 and 2026 logo files sit in the same folder with similar names and no "current" marker or archive split fails this rule, regardless of how good the 2026 file itself is.
