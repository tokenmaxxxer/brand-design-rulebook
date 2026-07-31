---
subject: issue-10
role: brand-design
loop_state: scope-proposed
---

# Proposal: brand-design methodology plugin set (issue-10)

**CANON REFERENCE ONLY — no duplication of canon text; this is a phase-1
design proposal, no working code included.** Every methodology element
named below is cited back to `docs/issue-1/proposals/
2026-07-31-brand-design-methodology-charter.md` /
`docs/issue-1/reports/brand-design/scout-brief.md` /
`docs/issue-1/reports/brand-design.md` by path — none of that text is
copied into this file. Every gate-construction pattern is cited back to
`pricing-rulebook`'s `pricing/hooks/methodology-gate.sh` and
`implementation-rulebook`'s `coding/hooks/*.sh` by path — none of that
script text is copied into this file either.

## Revision note (요구 정정 반영)

The prior revision of this proposal (reviewed in open PR #11) designed a
single deepened `directive.sh` plus one monolithic
`brand-design/hooks/methodology-gate.sh`. The approver's issue comment
("요구 정정") rejected that shape and required decomposition into a
**plugin set**: each adopted methodology facet becomes an independent,
self-contained plugin (freelunch/scout-level completeness — cf. core's
own built-in skill pattern of small, single-purpose, independently
loadable units), each registered as its own `.claude-plugin/
marketplace.json` entry, and the phase-1/phase-2 norms are each expressed
as a *combination* of these plugins rather than as one gate checking
everything. This revision keeps every judgment-criteria/required-element/
test-case/state-tracking-rationale/handbook idea from the prior
revision — none of it is discarded — and re-homes each piece under a
named plugin. See `docs/issue-10/reports/brand-design/survey.md` and
`docs/issue-10/reports/brand-design/scout-brief.md` for the underlying
research (unchanged, not redone here).

## Request (paraphrased intent)

Issue #10 asks this rulebook to turn the methodology already adopted in
issue-1 (landed in `brand-design/hooks/directive.sh`'s `PRODUCES` line and
`docs/issue-1/reports/brand-design.md`) into mechanical enforcement, at
the rigor bar `implementation-rulebook`'s hook machine sets, using
`pricing-rulebook`'s `methodology-gate.sh` as a construction reference —
but, per the approver's correction, organized as a set of independent
plugins rather than one deepened directive and one gate. Full survey
backing this proposal: `docs/issue-10/reports/brand-design/survey.md` and
`docs/issue-10/reports/brand-design/scout-brief.md`.

## Constraints

- Phase-1 only — no file is created, deleted, or edited outside
  `docs/issue-10/**` in this PR. Phase 2 (creating each plugin's
  directory, `directive.sh` fragment, gate script, `hooks.json` entries,
  tests, and the `.claude-plugin/marketplace.json` registrations
  described below) executes only after an `approvers.md` account's
  Approve or the issue comment `APPROVE issue-10/brand-design`, per
  contract v3 §19.
- Canon scripts remain referenced, never copied (core
  `docs/handbooks/canon-scripts.md`); every gate script named below is
  role-specific and local (same status as pricing's own copy — additive
  next to referenced core canon, not a vendored copy of a canon-manifest
  file).
- Role boundary and `write_scope` are unchanged across the whole plugin
  set: every gate below only ever inspects brand-design's own write
  surfaces (`docs/issue-<n>/proposals/*brand-design*.md`,
  `docs/issue-<n>/reports/brand-design.md`); the `HAND_OFF →
  ux-engineering` boundary is untouched.
- The norm source is issue-1's approved charter — this proposal invents no
  new domain methodology; it only designs the enforcement machinery
  (as a plugin set) for what issue-1 already adopted.
- This is still one proposal document — the plugin set is *described*
  here (names, ownership, components, composition); no plugin directory,
  no `marketplace.json` entry, and no code is actually created by this
  PR.

## Plugin set overview

Four plugins, each owning exactly one methodology concern drawn from the
charter and the prior revision's content. None is a stub: each carries a
directive fragment (the judgment-criteria prose it is responsible for),
a gate script (the mechanical check it enforces), and, where the prior
revision already specified one, a named test list. None duplicates
another's write-surface check — each gate checks only its own
required-element(s), so the four gates compose by all running (via
`hooks.json`'s `PreToolUse` array) rather than by one script calling
another.

| Plugin name | Methodology owned | Components (has / describes) | Composes into |
|---|---|---|---|
| `brand-design-guide-and-spec` | Brand guide entry + asset spec presence and cross-reference (charter's components 1–2) | directive fragment: `PRODUCES` sub-field judgment rules for "Brand guide entry" and "Asset spec" rows; gate: brand-guide-entry + asset-spec presence/cross-reference check (prior revision's required elements 1–2); test: `allow record-complete` (partial), `deny brand-guide-entry-missing`, `deny asset-spec-missing`, `allow not-applicable-logo` | Phase-2 only |
| `brand-design-wcag-consistency` | Consistency check vs. existing guide + WCAG contrast gate (charter's component 3) | directive fragment: the consistency-check and WCAG judgment rules (prior revision's PRODUCES table rows "Consistency check" and "WCAG contrast"); gate: WCAG ratio-token + pass/fail-word check, asymmetric "digits without label" fail (prior revision's required element 3); test: `deny wcag-number-unlabeled`, `allow no-new-pairing-early-exit` | Phase-2 only |
| `brand-design-system-handoff` | Design-system source paths + the Atomic-Design `HAND_OFF → ux-engineering` boundary discipline (charter's component 4) | directive fragment: the `HAND_OFF` clause (the "stop and hand off, do not silently absorb another role's scope" line, cited from `pricing/hooks/directive.sh`) plus the "Design-system source paths" PRODUCES row; gate: literal-path-token check outside the two write-surface regexes (prior revision's required element 4); test: `deny design-system-paths-missing`, `allow foreign-path` | Phase-2 only |
| `brand-design-kapferer-scope-guard` | Kapferer Physique-facet scope boundary (phase-1 acknowledgement) + prohibitions acknowledgement (phase-2 acknowledgement) | directive fragment: the `YOU_DECIDE` exclusion line (Personality/Culture/Relationship/Reflection/Self-image out of scope) and the 금지사항 (prohibitions) list; gate: (phase-1 mode) Kapferer-scope-boundary-acknowledgement check; (phase-2 mode) prohibitions-acknowledgement check (prior revision's required elements 5 and 6, run in different modes depending on which write-surface regex matched) | **Both** phase-1 and phase-2 (the one plugin whose gate branches by write-surface match) |

Kill-switch and fail-closed conventions are shared *design* across all
four gates (not shared code — no plugin depends on another's script):
each gate independently sets `trap __fc EXIT` as its literal first
executable statement and reads its own kill-switch env var
(`BRAND_DESIGN_GUIDE_AND_SPEC_GATE_OFF`,
`BRAND_DESIGN_WCAG_CONSISTENCY_GATE_OFF`,
`BRAND_DESIGN_SYSTEM_HANDOFF_GATE_OFF`,
`BRAND_DESIGN_KAPFERER_SCOPE_GUARD_GATE_OFF`), "off means off" per
pricing's own convention — cited, not copied, from
`pricing-rulebook/pricing/hooks/methodology-gate.sh`.

## Composition mapping (why each phase needs which plugins)

The prior revision already distinguished which required elements apply
only to a phase-1 proposal write vs. only to a phase-2 record write
(Kapferer-scope-boundary acknowledgement was phase-1-only; prohibitions
acknowledgement was phase-2-only; the other four elements applied to
records). This revision uses exactly that existing distinction to derive
composition, rather than inventing a new split:

- **Phase-1 proposal validity requires**: `brand-design-kapferer-scope-guard`
  (in its phase-1 mode) **active alone** among the four. A brand-design
  phase-1 proposal write (matching
  `^docs/issue-[0-9]+/proposals/.*brand-design.*\.md$`) is judged only on
  whether it names the Physique-facet-only scope boundary (or an
  explicit early-exit "no scoping question arose"); the other three
  plugins' gates exit 0 on a proposal-path write (not their business —
  identical pass-through behavior to pricing's own gate on foreign
  paths), since brand-guide-entry/asset-spec/WCAG/design-system-paths
  content and the prohibitions list are phase-2 record content, not
  proposal content.
- **Phase-2 record validity requires all four plugins active together**:
  `brand-design-guide-and-spec` (brand guide entry + asset spec present),
  `brand-design-wcag-consistency` (consistency check + WCAG number/pass-
  fail), `brand-design-system-handoff` (design-system source paths
  present), and `brand-design-kapferer-scope-guard` (in its phase-2 mode:
  prohibitions acknowledgement, not the scope-boundary check). A
  `docs/issue-<n>/reports/brand-design.md` write is only valid — passes
  every `PreToolUse` hook — when all four independently return allow;
  any single plugin's deny blocks the write regardless of the other
  three's verdict, matching the existing fail-closed, additive-not-
  replacement relationship to core's generic `record-fields-gate.sh`
  (cite: `docs/issue-10/reports/brand-design/survey.md`, "Core canon
  consulted") that the prior revision already established for the
  monolithic gate — unchanged here, just distributed across four
  scripts instead of one.
- This mapping is why `brand-design-kapferer-scope-guard` is the one
  plugin marked "Both" in the table above: it is the only methodology
  concern whose charter-derived check differs by phase (scope-boundary
  vs. prohibitions), so it is one plugin with a phase-aware gate rather
  than two, since both checks share the same directive-level content
  (the `YOU_DECIDE` exclusion line and the 금지사항 list are authored and
  maintained together, not independently).

## (a) Directive deepening, per plugin

Each plugin owns the slice of the deepened `PRODUCES`/`YOU_DECIDE`/
`USE_WHEN`/`HAND_OFF` content that the prior revision designed, following
the shape `implementation-rulebook/coding/hooks/directive.sh` uses
(heredoc-style `$'...'` bash strings), while staying inside
`core_role_directive`'s existing four-argument call shape (per issue-1's
plugin-reflection-plan constraint, unchanged here). Phase 2 would compose
these fragments back into the single `brand-design/hooks/directive.sh`
call (there is exactly one `directive.sh` for the role; the plugin split
is about which methodology concern *authors* which fragment of its
content and which gate enforces it, not about there being four separate
`directive.sh` files):

- **`brand-design-kapferer-scope-guard`** authors: the `YOU_DECIDE`
  scope-exclusion line (Personality/Culture/Relationship/Reflection/
  Self-image out of scope, cite: charter §"Justification tied to
  YOU_DECIDE", last bullet) and the 금지사항 (prohibitions) list, one
  line per prohibition, in `coding/hooks/directive.sh`'s "SCOPE-EXCEEDED
  RULE" imperative style: "no undocumented color/font introduced
  silently" (charter's consistency-check item (i), promoted to a
  standalone prohibition), "no WCAG number omitted or replaced with
  'looks fine'" (charter's own phrasing, promoted to a prohibition), "no
  token-systemization work performed by this role" (from the Atomic
  Design hand-off boundary).
- **`brand-design-guide-and-spec`** authors: the `PRODUCES` judgment rules
  for "Brand guide entry" and "Asset spec" (table rows below), plus the
  phase-1/phase-2 `USE_WHEN` split for when a brand-guide-entry or
  asset-spec write is expected (new/changed brand asset trigger).
- **`brand-design-wcag-consistency`** authors: the `PRODUCES` judgment
  rules for "Consistency check" and "WCAG contrast" (table rows below) —
  e.g. the WCAG rule stated explicitly ("no text/background pairing
  ships without a reported number; a fraction below the applicable
  threshold is a blocking fail, not a note") rather than left implicit
  in a noun phrase.
- **`brand-design-system-handoff`** authors: the `PRODUCES` judgment rule
  for "Design-system source paths" and the `HAND_OFF` clause itself
  ("stop and hand off, do not silently absorb another role's scope,
  record the hand-off point before opening the next role's session",
  cited as a generic cross-role discipline already present on
  `pricing/hooks/directive.sh`'s own `HAND_OFF` string, not
  pricing-specific content).

**Judgment criteria, stated explicitly (per facet, unchanged from the
prior revision, now attributed to the owning plugin):**

| PRODUCES facet | Executable judgment rule | Owning plugin |
|---|---|---|
| Brand guide entry | Every sub-field applicable to the asset class touched must appear with a concrete value, not "as needed" — if a sub-field is inapplicable (e.g. no logo involved), the record states "not applicable: <reason>" rather than omitting it silently. | `brand-design-guide-and-spec` |
| Asset spec | Values must be literal (hex/RGB, not swatch name); a value copied from the brand guide entry without restating the *rule* text is correct, restating the rule instead of the applied value is a fail. | `brand-design-guide-and-spec` |
| Consistency check | Must resolve to a named per-item pass/fail plus one consolidated verdict; a prose paragraph with no itemization is a fail regardless of content quality. | `brand-design-wcag-consistency` |
| WCAG contrast | Must carry an actual ratio number and state pass/fail against 4.5:1 (normal) or 3:1 (large); "looks fine" or omission is a fail. | `brand-design-wcag-consistency` |
| Design-system source paths | Must be literal repo paths, not descriptions of what ux-engineering "should" build. | `brand-design-system-handoff` |

## (b) Per-plugin gate design

Each plugin's gate is **modeled on** `pricing-rulebook/pricing/hooks/
methodology-gate.sh` (cite: `docs/issue-10/reports/brand-design/
scout-brief.md` must-bes 2–4, 7) but is its own script, registered under
its own plugin's `hooks/` directory, not a shared monolith. All four
share the same trigger/scope/content-resolution/fail-closed shape;
they differ only in which required element(s) each one checks and which
write-surface-regex mode(s) it runs in.

- **Trigger (all four)**: `PreToolUse`, matcher `Write|Edit|MultiEdit`,
  each plugin's own `hooks.json` contributing one entry to the set that
  fires on a brand-design write (no change to the existing
  `SessionStart` entry in the base `brand-design` plugin).
- **Write-surface scope (all four)**: `^docs/issue-[0-9]+/proposals/.*brand-design.*\.md$`
  (phase-1 proposal) and `^docs/issue-[0-9]+/reports/brand-design\.md$`
  (phase-2 record). Any write outside these two patterns exits 0
  immediately in every one of the four gates — identical pass-through
  behavior to pricing's own gate.
- **Content resolution (all four)**: identical to pricing's approach —
  full `content` for `Write`; `old_string`→`new_string` applied to
  current file text for `Edit`; each edit applied in sequence for
  `MultiEdit`; deny (fail-closed) if the resulting text can't be
  determined from the tool input, with the same message shape pricing's
  gate uses.
- **Fail-closed convention (all four, independently)**: `trap __fc EXIT`
  as the literal first executable statement, forcing any non-0/non-2
  exit to 2, plus a `try/except`-wrapped Python judge body that also
  forces exit 2 on internal error.
- **Kill switch (one per plugin, independently)**: see the per-plugin env
  var names listed in "Plugin set overview" above.

**Per-plugin required-element check:**

- `brand-design-guide-and-spec` gate (phase-2 record writes only —
  exits 0 on a proposal-path write, that check belongs to
  `brand-design-kapferer-scope-guard`):
  1. **Brand guide entry present** — substring/structure check for at
     least one of: logo usage rule, color value (hex/rgb pattern), a
     typography-role keyword (heading/body/caption), voice/tone note,
     imagery style note, do's/don'ts — with an explicit early-exit
     allowance ("not applicable: <reason>" per sub-field).
  2. **Asset spec present** — a color/hex pattern or explicit file-format/
     path token, distinct from the brand-guide-entry occurrence (i.e. the
     values must appear a second time as "applied," not just once as
     "ruled").
- `brand-design-wcag-consistency` gate (phase-2 record writes only):
  3. **Consistency-check-with-WCAG present** — presence of a WCAG
     ratio-like token (`\d+(\.\d+)?\s*:\s*1`) AND a pass/fail word
     ("pass"/"fail"/"AA"), mirroring pricing's own "digits present but no
     labeling language" asymmetric check; absence of any color pairing is
     an explicit early-exit ("no new text/background pairing
     introduced").
- `brand-design-system-handoff` gate (phase-2 record writes only):
  4. **Design-system source paths present** — a literal path-shaped
     token (contains `/`) outside of the two write-surface patterns
     themselves.
- `brand-design-kapferer-scope-guard` gate (both write-surface patterns,
  branching by which one matched):
  5. On a **phase-1 proposal-path** match: **Kapferer-scope-boundary
     acknowledgement** — a statement that only the Physique/visual facet
     is addressed, OR an explicit early-exit note that no scoping
     question arose for this asset.
  6. On a **phase-2 record-path** match: **Prohibitions acknowledgement**
     — the record must name, for each of the 금지사항 lines this same
     plugin authors in the directive, either "not triggered" or how it
     was avoided.

**Relationship to core's generic §20 gate**: all four gates are additive
on top of `record-fields-gate.sh` (cite: `docs/issue-10/reports/
brand-design/survey.md`, "Core canon consulted"), never a replacement —
identical relationship pricing's own gate declares in its header
comment. This is the resolution of the open item issue-9's record left
for a future approver (role-specific gate vs. accepting the generic-only
gap): **this proposal's answer is still to build role-specific gates**,
now as four small scripts rather than one, since issue-10 is explicitly
the maturation round asking for exactly this depth.

**State-tracking**: **not adopted**, unchanged from the prior revision,
as an explicit design decision (see scout-brief.md's "Skip" section,
first bullet) — the charter's adopted methodology has no cross-turn
ordering constraint analogous to coding/verify's finding-resolution
loop; each plugin's per-write field-presence check already enforces the
only ordering that matters — that a *finished* write contains that
plugin's required element(s), checked at write time. This is unaffected
by the move to a plugin set: if a future issue's approver disagrees, a
`.brand-design-<state>` file plus a companion reader/writer hook pair
would be its own fifth plugin (or an addition to one of the four),
described but not built in this phase.

## (c) Marketplace registration (described, not created)

Each plugin would be registered as its own entry in `.claude-plugin/
marketplace.json`, alongside (not replacing) the existing `brand-design`
entry, following the source-path convention already used there:

    {
      "name": "brand-design-guide-and-spec",
      "source": "./brand-design-guide-and-spec",
      "description": "Owns brand guide entry + asset spec presence/cross-reference for brand-design phase-2 records."
    },
    {
      "name": "brand-design-wcag-consistency",
      "source": "./brand-design-wcag-consistency",
      "description": "Owns consistency-check + WCAG contrast gate for brand-design phase-2 records."
    },
    {
      "name": "brand-design-system-handoff",
      "source": "./brand-design-system-handoff",
      "description": "Owns design-system source-paths check + the ux-engineering hand-off boundary discipline."
    },
    {
      "name": "brand-design-kapferer-scope-guard",
      "source": "./brand-design-kapferer-scope-guard",
      "description": "Owns Kapferer Physique-facet scope acknowledgement (phase-1) and prohibitions acknowledgement (phase-2)."
    }

Each plugin's own `.claude-plugin/plugin.json` would declare a
`dependencies` note identical in spirit to the existing `brand-design/
.claude-plugin/plugin.json`'s note (requires core/warrant plugins
installed alongside), plus a note that all four brand-design-* plugins
are meant to be installed together as a set — none is independently
useful without the base `brand-design` plugin's `SessionStart` wiring
and `write_scope`, which remain unchanged and un-split. This is
description only; no `.claude-plugin/marketplace.json` edit and no
plugin directory is created by this PR.

## (d) Gate tests (design only, no test code included), per plugin

**Modeled on** `implementation-rulebook/tests/run-gate-tests.sh` (cite:
survey.md must-be 6). Phase 2 would add one test file per plugin, each
co-located with its own gate (`brand-design-<plugin-suffix>/hooks/tests/
methodology-gate-tests.sh`), matching this repo's existing convention of
no repo-root `tests/` directory (per issue-5's survey/precedent) —
**this proposal recommends the colocated form**, left as an
approver-visible choice, unchanged from the prior revision's
recommendation.

Same real-subprocess shape for every plugin's test file: `mktemp -d &&
git init -q`, a synthetic JSON tool-call payload piped on stdin to that
plugin's own gate script, exit code mapped to `allow`/`deny`/`exit-N`,
`want` vs. `got` asserted via a `report()` helper identical in spirit to
the reference harness's own.

**Named cases, per plugin (unchanged content from the prior revision,
now split by owning plugin):**

- `brand-design-guide-and-spec`: `deny brand-guide-entry-missing`, `deny
  asset-spec-missing`, `allow not-applicable-logo` (early-exit case: "not
  applicable: no logo in this asset" passes without a literal logo
  rule), `allow foreign-path` (a write outside both regex patterns
  passes through untouched — mirrors the reference harness's own
  `foreign-path` case).
- `brand-design-wcag-consistency`: `deny wcag-number-unlabeled` (digits
  present, no pass/fail word — mirrors pricing's own `labeled-numbers`
  asymmetric case), `allow no-new-pairing-early-exit`, `allow
  foreign-path`.
- `brand-design-system-handoff`: `deny design-system-paths-missing`,
  `allow foreign-path`.
- `brand-design-kapferer-scope-guard`: `deny scope-boundary-missing`
  (proposal-path write, no Physique-only statement and no early-exit
  note), `allow scope-boundary-present`, `deny
  prohibitions-not-acknowledged` (record-path write missing the
  acknowledgement), `allow prohibitions-acknowledged`, `allow
  foreign-path`, `allow kill-switch-off` (this plugin's own env var set,
  gate short-circuits to allow — each of the other three plugins would
  carry the equivalent case for its own kill-switch env var).

## (e) Agents/checklists

**Not adopted as a new `agents/` subagent for any of the four plugins** —
explicit design decision (cite: scout-brief.md's adopt/skip summary, item
4), unchanged from the prior revision. The charter's "required
components, per deliverable" list is already checklist-shaped and does
not describe a repeated, multi-step *procedure* a subagent would run
(unlike `warrant-hunter`). Instead:

- **Add `docs/handbooks/brand-design/methodology.md`**, modeled on
  `pricing-rulebook/docs/handbooks/pricing/methodology.md`'s split: a
  "Phase-1 proposal checklist" section (content owned by
  `brand-design-kapferer-scope-guard`'s phase-1 mode) and a "Phase-2
  record checklist" section organized by the other three plugins' owned
  concerns plus this plugin's phase-2 mode, each listing the charter's
  required components as worked guidance (the reasoning a regex can't
  check). This handbook stays a single file — the plugin split organizes
  its *sections*, not separate handbook files per plugin.

## What is out of scope

- Actually creating any of the four plugin directories, their
  `.claude-plugin/plugin.json` files, their `hooks/*.sh` gate scripts,
  their `hooks/hooks.json` entries, their test files, the
  `.claude-plugin/marketplace.json` edits registering them, or
  `docs/handbooks/brand-design/methodology.md` — phase 2 only, after
  Approve.
- Editing the existing base `brand-design/hooks/directive.sh` or
  `brand-design/.claude-plugin/plugin.json` — phase 2 only.
- Writing `docs/issue-10/reports/brand-design.md` (the phase-2 record
  file) — off limits this phase.
- Building state-tracking machinery (lock files, ordering gates) — this
  proposal's explicit recommendation is not to build it (see (b)), but
  the decision is named for the approver rather than silently
  foreclosed.
- Choosing repo-root `tests/` vs. colocated per-plugin `hooks/tests/` is
  recommended (colocated) but left as an approver-visible choice.
- Any change to `warrant-hunter`, `record-fields-gate.sh`, or any other
  core-canon-referenced gate.
- Any change to `ux-engineering`'s plugin or the `HAND_OFF` boundary
  itself.
- Further subdividing the four plugins into smaller units, or merging
  them back into fewer than four — this proposal's decomposition is the
  recommended cut; a different cut is an approver-visible choice, not
  silently foreclosed, but is not designed here.

## How this will be judged

- `docs/issue-10/reports/brand-design/survey.md` and
  `docs/issue-10/reports/brand-design/scout-brief.md` exist, cite real
  internal file paths (not external URLs), and state must-bes/gap/
  adopt/skip per this repo's scouting convention.
- This proposal file exists at `docs/issue-10/proposals/
  2026-07-31-brand-design-directive-hardening.md` with frontmatter
  `subject: issue-10`, `role: brand-design`, `loop_state: scope-proposed`.
- **The plugin table (Plugin set overview) is present** and lists, for
  each of the four plugins: name, the single methodology concern it
  owns, its components (directive fragment/gate/agent/test — stating
  which it has), and which phase(s) it composes into.
- **The composition mapping section is present** and states explicitly
  which plugin(s) phase-1 proposal validity requires and which plugin(s)
  phase-2 record validity requires, derived from the existing phase-1-
  only vs. phase-2-only distinction already present in the charter/prior
  revision (not a newly invented split).
- Every design element traces to either a cited issue-1 charter section
  (methodology content) or a cited pricing-rulebook/implementation-
  rulebook file path (gate-construction pattern) — no canon text is
  duplicated verbatim in this file.
- The state-tracking question and the tests-location question are each
  named as an explicit open decision for the approver, not silently
  resolved.
- No file outside `docs/issue-10/**` is modified by this PR.
- No file under `src/` or `test/` is created or modified by this PR (none
  exist in this rulebook's tree; this proposal does not introduce them).
- No `.claude-plugin/marketplace.json` edit, plugin directory, or gate
  script actually exists as a result of this PR — the plugin set is
  described, not built.
