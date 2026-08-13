---
axis: color-combination-visibility
rule_count_floor: 3
tier: rich
---

# Color-combination visibility rules

Practitioner + standards + academic rules for which color combinations
preserve visibility and recognition in brand-facing material (logos,
brand-color-on-background pairings, brand color as UI accent).

## Decision rules

### 1. Body/UI text pairs must clear WCAG contrast; brand-mark text is exempt but should still clear it when feasible
- **Condition**: when a brand color pair is used to render body copy, labels, or any interactive text/control (not the standalone logo mark itself)
- **Choice**: pick a foreground/background pair with contrast ratio >= 4.5:1 for normal text (>= 3:1 for large text, 18pt+/14pt+bold); when the pair is the logo's own logotype rendered as static brand mark (not acting as a link or interactive control), the ratio requirement does not block ship, but the guide should still record the pair's actual ratio and prefer a variant that clears 4.5:1 when brand constraints allow it
- **Why**: WCAG 1.4.3 sets 4.5:1/3:1 as the threshold empirically tied to legibility for users with low vision; the logo exemption exists only because logos are assumed to already be constrained by identity rules, and that exemption breaks down the moment the mark also functions as a clickable/interactive element
- **Source**: W3C, "Understanding Success Criterion 1.4.3: Contrast (Minimum)", https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html ; WebAIM, "Contrast and Color Accessibility", https://webaim.org/articles/contrast/
- **Counter-example test**: a brand-color pairing at 2.8:1 used for a footer link styled in brand color on brand-color background fails this rule (interactive text, below 3:1) even though the same pair on the static logo lockup would not be blocked by 1.4.3 alone.

### 2. Reserve a single dominant brand hue for the primary recognition trigger; do not let a secondary/accent palette compete for that role
- **Condition**: when defining (or auditing) which color(s) a brand system treats as its primary identity signal across touchpoints
- **Choice**: designate one hue (not a hue family, not "our top 3 colors") as the brand's primary recognition color, and keep secondary/accent colors visually subordinate (smaller area, lower saturation, or restricted to specific non-identity contexts) rather than co-equal
- **Why**: single-color-system brands see a measured lift in unaided recall versus multi-color systems, and logo recognition research shows the "memory color effect" (a stored, stable hue expectation) only forms reliably under high familiarity — familiarity is easier to build around one consistent hue than a rotating set
- **Source**: Loeffler, T.A., et al., cited via industry synthesis in Review42, "Color Psychology Statistics", https://resources.review42.com/color-psychology-facts/ ; Kim & Lee, "Memory Color Effect Induced by Familiarity of Brand Logos", PLOS ONE, https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0068474
- **Counter-example test**: a style guide that lists five "brand colors" with no stated primary/secondary hierarchy, all used at roughly equal frequency across the last 10 shipped assets, fails this rule even if each individual color independently passes contrast checks.

### 3. Remove low-familiarity accent colors from a mature guide rather than adding new ones to chase trend cycles
- **Condition**: when a brand's palette has grown past its original set (new accent colors added over successive campaigns/rebrand touch-ups) and the guide is due for review
- **Choice**: audit actual usage frequency of each accent color across shipped assets in the review window; drop (do not retire-but-keep-optional) any accent color below a set usage floor from the published palette, rather than leaving it in the guide "just in case" alongside newly proposed colors
- **Why**: the memory-color effect that makes a brand's hue recognizable only strengthens with a small, stable, high-familiarity set; every additional low-usage color dilutes the recognition signal the primary-hue rule (#2) depends on, and teams default to *adding* a new accent rather than *removing* a stale one because subtractive changes are systematically overlooked as an option
- **Source**: Adams, G.S., Converse, B.A., Hales, A.H., Klotz, L.E., "People systematically overlook subtractive changes", Nature 592, 258-261 (2021), https://www.nature.com/articles/s41586-021-03380-y
- **Counter-example test**: a palette page that has only ever grown (7 accent swatches added over 3 years, 0 removed, no usage-frequency column) fails this rule regardless of how well any single swatch passes contrast — the growth-only pattern itself is the violation.
