---
axis: logo-clear-space-and-minimum-size
rule_count_floor: 3
tier: rich
---

# Logo clear-space and minimum-size rules

## Decision rules

### 1. Define clear space as a ratio of the logo's own height/letterform, not a fixed absolute unit
- **Condition**: when specifying how much surrounding empty space a logo lockup requires in any layout
- **Choice**: express the minimum clear-space margin as a multiple of a unit intrinsic to the mark itself — the cap-height/x-height of a defining letterform (the "X" unit method, e.g. Google's use of the "G" height, PayPal's use of the "P" height) or a height-based ratio (e.g. top/side margins = 0.4X, bottom margin = 0.5X of logo height X) — never a flat inch/pixel value alone
- **Why**: an absolute unit breaks the moment the logo is scaled (a 2" clear space looks generous next to a 6" logo and crowded next to a 0.5" logo); a ratio scales with the mark automatically and is the convention every surveyed guideline source converges on
- **Source**: Koko (Ling) Lv, "How to design Clear Space for a logo?", Medium, https://kokolv.medium.com/how-to-design-clear-space-for-a-logo-291359020819 ; Johns Hopkins Medicine Brand Guidelines, "Clear Space and Minimum Size", https://brand.hopkinsmedicine.org/brand/branding-guidelines/logo-guidelines/clear-space-and-minimum-size
- **Counter-example test**: a guide stating "always keep 0.5 inches of clear space" with no reference to logo height fails this rule — it will visibly under-protect any lockup scaled above roughly business-card size and over-constrain any lockup scaled below it.

### 2. Set separate minimum-size floors for print and for digital, and for wordmark vs. logomark-alone
- **Condition**: when a lockup must be reproduced small enough that legibility/registration risk becomes real (favicons, app icons, business cards, footer stamps)
- **Choice**: publish at least two numeric floors — a print floor (commonly 1.25"-1.5" for the primary horizontal/vertical lockup) and a digital floor (commonly 20px-50px depending on whether the mark carries fine detail) — and a lower floor for a simplified logomark-only variant used below the wordmark's floor, rather than one number covering all media and both variants
- **Why**: print and screen have different minimum legible feature sizes (print resolution vs. pixel rendering + anti-aliasing), and a wordmark's smallest legible size is bounded by its finest letterform stroke while a logomark-only variant is usually simpler and can go smaller without breaking legibility
- **Source**: Vistaprint, "Logo usage guidelines: What they are and how to set them", https://www.vistaprint.com/hub/logo-usage-guidelines ; SolidRun Brand Guidelines, https://www.solid-run.com/brand-guidelines/
- **Counter-example test**: a guide that gives one minimum size ("never smaller than 100px") applied identically to a favicon, a footer wordmark, and a printed banner fails this rule — it does not distinguish medium or variant, so at least one of those contexts will be either needlessly restricted or actually illegible.

### 3. Cut logo variants that exist only for a single obsolete campaign/medium rather than keeping every historical version "just in case"
- **Condition**: when a brand guide's logo-variant appendix has accumulated versions tied to a specific past campaign, discontinued product line, or a medium the brand no longer produces for
- **Choice**: actively remove (not archive-in-the-live-guide) variants with zero current production use from the guide's active variant set; keep a separate, clearly-labeled historical archive outside the working guide if institutional memory is needed
- **Why**: every additional "still valid" variant increases the chance a downstream producer picks the wrong one, and the guide's own clarity is a scarce resource — teams asked to update a guide default to adding the new variant next to the old ones rather than pruning, which is the same additive bias documented for change tasks generally
- **Source**: Adams, G.S., Converse, B.A., Hales, A.H., Klotz, L.E., "People systematically overlook subtractive changes", Nature 592, 258-261 (2021), https://www.nature.com/articles/s41586-021-03380-y ; Bynder, "Turning brand governance into a competitive advantage", https://www.bynder.com/en/blog/what-is-brand-governance/
- **Counter-example test**: a variant appendix listing 9 logo lockups where only 3 appear in any asset shipped in the last 12 months, with no archive/active split, fails this rule.
