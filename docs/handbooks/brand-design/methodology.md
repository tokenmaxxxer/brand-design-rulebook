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

## Open decisions this handbook does not resolve

- **State-tracking**: not adopted (see `docs/issue-10/proposals/
  2026-07-31-brand-design-directive-hardening.md`, section (b),
  "State-tracking"). The charter's methodology has no cross-turn
  ordering constraint; each plugin's per-write check already enforces
  the only ordering that matters.
- **Tests location**: colocated per plugin (`brand-design-<suffix>/
  hooks/tests/methodology-gate-tests.sh`), matching this repo's existing
  convention of no repo-root `tests/` directory.
