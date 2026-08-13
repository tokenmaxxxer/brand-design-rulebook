---
axis: typography-pairing
rule_count_floor: 3
tier: rich
---

# Typography pairing rules

## Decision rules

### 1. Pair for contrast, not similarity — serif+sans over near-identical sans+sans
- **Condition**: when selecting a second typeface to pair with an already-chosen primary brand typeface for a two-tier hierarchy (headline/body, display/UI)
- **Choice**: default to a structurally distinct pair (serif + sans-serif, or a high-contrast display face + a neutral low-contrast workhorse face) over two faces from the same structural family that merely differ in weight
- **Why**: the structural difference (feet vs. no feet, stroke-contrast level) does the hierarchy work automatically — two same-family faces at similar weight force the layout itself to carry all the hierarchy signal and read as "almost matching" rather than deliberately paired
- **Source**: 99designs, "3 principles you need to pair typefaces perfectly", https://99designs.com/blog/tips/typeface-pairing-principles/ ; The Crit, "Font Pairing Guide: Rules, Tools, and Combinations That Work", https://thecrit.co/resources/font-pairing-guide
- **Counter-example test**: pairing Helvetica Regular headlines with Arial Regular body copy fails this rule — both are low-contrast grotesque sans faces with near-identical proportions, so the pairing reads as an inconsistency (wrong font substituted) rather than an intentional two-tier system.

### 2. Match contrast level between the two chosen faces; don't pair a fragile high-contrast serif with a heavy low-contrast display sans
- **Condition**: once two structurally distinct faces are shortlisted (rule 1 satisfied) and a final pair must be locked for the brand system
- **Choice**: pick a second face whose own stroke-contrast/weight character sits in a compatible register with the first — a high-contrast display serif (e.g. Playfair/Fraunces-class) pairs with a clean, fairly neutral sans (e.g. Inter/Source-Sans-class), while a low-contrast slab serif pairs with a humanist sans of similar visual weight
- **Why**: two faces that are individually striking but pull toward opposite ends of the contrast/weight spectrum compete for dominance on the page instead of forming a hierarchy — "one loud, one quiet" is the rule of thumb every source converges on for why some serif/sans pairs feel wrong despite passing the structural-contrast rule
- **Source**: The Crit, "Font Pairing Guide", https://thecrit.co/resources/font-pairing-guide ; Canva, "The Ultimate Guide to Font Pairing", https://www.canva.com/learn/the-ultimate-guide-to-font-pairing/
- **Counter-example test**: pairing a fragile high-contrast display serif (thin hairlines) as body-text-sized copy against a heavy black-weight grotesque sans headline fails this rule at any size — both faces demand visual dominance and the hairline serif becomes illegible at small sizes on top of the clash.

### 3. Cap the brand system at two-to-three typefaces total; retire an unused third/fourth face rather than let it accumulate from campaign-specific additions
- **Condition**: when an audit of shipped brand material turns up more distinct typefaces in active use than the guide's own stated type system lists
- **Choice**: remove typefaces from the active brand type system that exist only because a past campaign or a single team introduced them, folding any material need they served into the two-to-three-face core system instead of formally adding a fourth/fifth face to "cover" it
- **Why**: readability and brand coherence both degrade past two-to-three typefaces per system — every source on font pairing converges on a 2-3 face ceiling — but the failure mode in practice is not overshooting on day one, it's each new campaign silently adding "just one more" face and nobody removing the earlier one-off later
- **Source**: Visme, "A Non-Designer's Guide to Pairing Fonts", https://visme.co/blog/pairing-fonts/ ; Adams et al., "People systematically overlook subtractive changes", Nature 592 (2021), https://www.nature.com/articles/s41586-021-03380-y
- **Counter-example test**: a brand guide that states "2 typefaces" in its type-system page while an asset audit finds 5 distinct typefaces across the last year's shipped materials fails this rule — the guide's additive drift was never pruned back to its own stated ceiling.
