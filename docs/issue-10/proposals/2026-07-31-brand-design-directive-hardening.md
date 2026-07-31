---
subject: issue-10
role: brand-design
loop_state: scope-proposed
---

# Proposal: brand-design directive hardening + methodology gate (issue-10)

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

## Request (paraphrased intent)

Issue #10 asks this rulebook to turn the methodology already adopted in
issue-1 (landed in `brand-design/hooks/directive.sh`'s `PRODUCES` line and
`docs/issue-1/reports/brand-design.md`) into mechanical enforcement, at
the rigor bar `implementation-rulebook`'s hook machine sets, using
`pricing-rulebook`'s `methodology-gate.sh` as the direct construction
model. Full survey backing this proposal:
`docs/issue-10/reports/brand-design/survey.md` and
`docs/issue-10/reports/brand-design/scout-brief.md`.

## Constraints

- Phase-1 only — no file is created, deleted, or edited outside
  `docs/issue-10/**` in this PR. Phase 2 (writing `brand-design/hooks/
  methodology-gate.sh`, editing `directive.sh`/`hooks.json`, adding
  `tests/`) executes only after an `approvers.md` account's Approve or the
  issue comment `APPROVE issue-10/brand-design`, per contract v3 §19.
- Canon scripts remain referenced, never copied (core
  `docs/handbooks/canon-scripts.md`); this proposal's new
  `methodology-gate.sh` is role-specific and local (same status as
  pricing's own copy — additive next to referenced core canon, not a
  vendored copy of a canon-manifest file).
- Role boundary and `write_scope` are unchanged: brand-design's gate only
  ever inspects brand-design's own write surfaces
  (`docs/issue-<n>/proposals/*brand-design*.md`,
  `docs/issue-<n>/reports/brand-design.md`); the `HAND_OFF →
  ux-engineering` boundary is untouched.
- The norm source is issue-1's approved charter — this proposal invents no
  new domain methodology; it only designs the enforcement machinery for
  what issue-1 already adopted.

## (a) Directive deepening

**Design**: replace `directive.sh`'s current single-sentence `PRODUCES`
value with per-phase, multi-line strings, following the shape
`implementation-rulebook/coding/hooks/directive.sh` uses (heredoc-style
`$'...'` bash strings holding paragraph-structured text), while staying
inside `core_role_directive`'s existing four-argument call shape (per
issue-1's own plugin-reflection-plan constraint, unchanged here).

For each of the four `core_role_directive` arguments, phase-1 asks for:

- **`YOU_DECIDE`**: keep the existing one-line mandate
  ("브랜드 정체성이 시각적으로 일관되는가") as the header, but append the
  scope boundary already justified in the charter — Kapferer's Physique
  facet only (cite: charter §"Justification tied to YOU_DECIDE", last
  bullet) — stated as an explicit exclusion line ("Personality/Culture/
  Relationship/Reflection/Self-image 등 브랜드 전략/포지셔닝은 이 역할의
  결정 범위 밖").
- **`USE_WHEN`**: split into a phase-1 sub-section (what triggers a
  brand-design proposal: new/changed brand asset) and a phase-2
  sub-section (what triggers the record write), mirroring
  `coding/hooks/directive.sh`'s `USE_WHEN`'s own RESEARCH/CURRENT-STATE-
  SURVEY/PROPOSAL phase split.
- **`PRODUCES`**: expand the current single-sentence sub-field list (cite:
  charter §"Required components, per deliverable") into named
  judgment-criteria prose per component — e.g. for the WCAG check, state
  the judgment rule explicitly ("no text/background pairing ships without
  a reported number; a fraction below the applicable threshold is a
  blocking fail, not a note") rather than leaving the threshold's
  enforcement implicit in a noun phrase. Add an explicit 금지사항
  (prohibitions) list, one line per prohibition, in the same imperative
  style as `coding/hooks/directive.sh`'s "SCOPE-EXCEEDED RULE": e.g. "no
  undocumented color/font introduced silently" (already implied by the
  charter's consistency-check item (i), promoted here to a named,
  standalone prohibition), "no WCAG number omitted or replaced with
  'looks fine'" (charter's own phrasing, promoted to a prohibition), "no
  token-systemization work performed by this role" (from the Atomic
  Design hand-off boundary).
- **`HAND_OFF`**: keep the existing `ux-engineering` arrow; add the same
  "stop and hand off, do not silently absorb another role's scope, record
  the hand-off point before opening the next role's session" clause
  `pricing/hooks/directive.sh` already carries on its own `HAND_OFF`
  string, since it is a generic cross-role discipline, not
  pricing-specific content.

**Judgment criteria, stated explicitly (per facet):**

| PRODUCES facet | Executable judgment rule |
|---|---|
| Brand guide entry | Every sub-field applicable to the asset class touched must appear with a concrete value, not "as needed" — if a sub-field is inapplicable (e.g. no logo involved), the record states "not applicable: <reason>" rather than omitting it silently. |
| Asset spec | Values must be literal (hex/RGB, not swatch name); a value copied from the brand guide entry without restating the *rule* text is correct, restating the rule instead of the applied value is a fail. |
| Consistency check | Must resolve to a named per-item pass/fail plus one consolidated verdict; a prose paragraph with no itemization is a fail regardless of content quality. |
| WCAG contrast | Must carry an actual ratio number and state pass/fail against 4.5:1 (normal) or 3:1 (large); "looks fine" or omission is a fail. |
| Design-system source paths | Must be literal repo paths, not descriptions of what ux-engineering "should" build. |

## (b) Methodology gate design

**Modeled directly on** `pricing-rulebook/pricing/hooks/
methodology-gate.sh` (cite: `docs/issue-10/reports/brand-design/
scout-brief.md` must-bes 2–4, 7). Phase 2 would add
`brand-design/hooks/methodology-gate.sh`:

- **Trigger**: `PreToolUse`, matcher `Write|Edit|MultiEdit` (added to
  `brand-design/hooks/hooks.json` alongside the existing `SessionStart`
  entry; no change to `SessionStart`'s own wiring).
- **Write-surface scope** (regex, exactly as narrow as pricing's own):
  `^docs/issue-[0-9]+/proposals/.*brand-design.*\.md$` (phase-1 proposals)
  and `^docs/issue-[0-9]+/reports/brand-design\.md$` (phase-2 record).
  Any write outside these two patterns exits 0 immediately (not this
  gate's business) — identical pass-through behavior to pricing's gate.
- **Content resolution**: identical to pricing's approach — full
  `content` for `Write`; `old_string`→`new_string` applied to current file
  text for `Edit`; each edit applied in sequence for `MultiEdit`; deny
  (fail-closed) if the resulting text can't be determined from the tool
  input, with the same message shape pricing's gate uses ("write the full
  document with Write, or use an Edit/MultiEdit whose old_string
  matches").
- **Fail-closed convention**: `trap __fc EXIT` as the literal first
  executable statement (before any `set`/`source`), forcing any non-0/
  non-2 exit to 2, plus a `try/except`-wrapped Python judge body that also
  forces exit 2 on internal error — the same two-layer fail-closed shape
  every reference gate in the survey uses.
- **Kill switch**: `BRAND_DESIGN_METHODOLOGY_GATE_OFF=1`, read the same
  way pricing's gate reads `PRICING_METHODOLOGY_GATE_OFF` ("off means
  off" — only an explicitly-empty/0/false/no/off value disables it).
- **Required elements checked** (brand-design's own vocabulary, drawn from
  the charter, not pricing's six):
  1. **Brand guide entry present** — substring/structure check for at
     least one of: logo usage rule, color value (hex/rgb pattern), a
     typography-role keyword (heading/body/caption), voice/tone note,
     imagery style note, do's/don'ts — with an explicit early-exit
     allowance ("not applicable: <reason>" per sub-field, mirroring the
     directive's own "not applicable" allowance above) so a genuinely
     inapplicable sub-field does not force a false field into the text.
  2. **Asset spec present** — a color/hex pattern or explicit file-format/
     path token, distinct from the brand-guide-entry occurrence (i.e. the
     values must appear a second time as "applied," not just once as
     "ruled").
  3. **Consistency-check-with-WCAG present** — presence of a WCAG
     ratio-like token (`\d+(\.\d+)?\s*:\s*1`) AND a pass/fail word
     ("pass"/"fail"/"AA"), mirroring pricing's own "digits present but no
     labeling language" asymmetric check (numbers without a pass/fail
     label are a fail, absence of any color pairing is an explicit
     early-exit: "no new text/background pairing introduced").
  4. **Design-system source paths present** — a literal path-shaped token
     (contains `/`) outside of the two write-surface patterns themselves.
  5. **Kapferer-scope-boundary acknowledgement** — for a proposal only
     (not the record): a statement that only the Physique/visual facet is
     addressed, OR an explicit early-exit note that no scoping question
     arose for this asset — this is the field-presence analogue of the
     charter's scope discipline, checked so a proposal cannot silently
     drift into brand-strategy territory without at least naming that it
     didn't.
  6. **Prohibitions acknowledgement** — the record (phase-2 only) must
     name, for each of the 금지사항 lines added to the directive in (a),
     either "not triggered" or how it was avoided — this is the
     mechanism that ties the directive's prohibitions to something
     checkable, rather than leaving them as unenforced prose.
- **Relationship to core's generic §20 gate**: this gate is additive on
  top of `record-fields-gate.sh` (cite: `docs/issue-10/reports/
  brand-design/survey.md`, "Core canon consulted"), never a replacement —
  identical relationship pricing's own gate declares in its header
  comment. This is the resolution of the open item issue-9's record left
  for a future approver (role-specific gate vs. accepting the generic-
  only gap): **this proposal's answer is to build the role-specific
  gate**, since issue-10 is explicitly the maturation round asking for
  exactly this.

**State-tracking**: **not adopted**, as an explicit design decision (see
scout-brief.md's "Skip" section, first bullet) — the charter's adopted
methodology (brand guide entry → asset spec → consistency check) has no
cross-turn ordering constraint analogous to coding/verify's
finding-resolution loop (nothing in the charter requires "step 2 cannot
start until step 1's state file says so" across separate tool calls); the
gate's per-write field-presence check already enforces the only ordering
that matters — that a *finished* write contains all required elements,
checked at write time, not that intermediate steps happen in a fixed
sequence across turns. If a future issue's approver disagrees, item 2's
design here (regex scope + field list) is unaffected; only a
`.brand-design-<state>` file plus a companion reader/writer hook pair
(mirroring `hunt-guard.sh`/`hunt-state.sh`) would need to be added,
described but not built in this phase.

## (c) Gate tests (design only, no test code included)

**Modeled on** `implementation-rulebook/tests/run-gate-tests.sh` (cite:
survey.md must-be 6). Phase 2 would add a repo-root `tests/
run-gate-tests.sh`:

- Same real-subprocess shape: `mktemp -d && git init -q`, a synthetic JSON
  tool-call payload piped on stdin to `brand-design/hooks/
  methodology-gate.sh`, exit code mapped to `allow`/`deny`/`exit-N`, `want`
  vs. `got` asserted via a `report()` helper identical in spirit to the
  reference harness's own.
- **Named cases** (allow/deny pairs per required element, matching the
  reference harness's naming convention of `<verdict>-<short-name>`):
  `allow record-complete` (all six elements present), `deny
  brand-guide-entry-missing`, `deny asset-spec-missing`, `deny
  wcag-number-unlabeled` (digits present, no pass/fail word — mirrors
  pricing's own `labeled-numbers` asymmetric case), `deny
  design-system-paths-missing`, `allow not-applicable-logo` (an early-exit
  case: "not applicable: no logo in this asset" passes without a literal
  logo rule), `allow foreign-path` (a write outside both regex patterns
  passes through untouched — mirrors the reference harness's own
  `foreign-path` case for `record-fields-gate.sh`), `allow
  kill-switch-off` (env var set, gate short-circuits to allow).
- **File location**: `brand-design/hooks/tests/methodology-gate-tests.sh`
  (co-located with the gate, matching this repo's existing convention of
  no repo-root `tests/` directory today — `implementation-rulebook` uses a
  repo-root `tests/`, but this repo's own prior precedent, per issue-5's
  survey, is that this rulebook has no such directory yet and
  `stub-check.sh` was invoked directly rather than via a wrapper; phase 2
  should decide, as an explicit approver-visible choice, whether to
  introduce a repo-root `tests/run-gate-tests.sh` (matching
  implementation-rulebook exactly) or keep the test file colocated under
  `brand-design/hooks/tests/` (matching this repo's own prior structure
  before issue-5's stub removal) — **this proposal recommends the
  colocated form**, since it matches this repo's own historical layout
  and nothing in issue-10 requires cross-role test-harness parity, only
  parity of rigor/shape).

## (d) Agents/checklists

**Not adopted as a new `agents/` subagent** — explicit design decision
(cite: scout-brief.md's adopt/skip summary, item 4). The charter's
"required components, per deliverable" list (cite:
`docs/issue-1/reports/brand-design/scout-brief.md` "Adopt" section) is
already checklist-shaped and does not describe a repeated, multi-step
*procedure* a subagent would run (unlike `warrant-hunter`, which is
dispatched repeatedly with bounded cadence). Instead:

- **Add `docs/handbooks/brand-design/methodology.md`**, modeled on
  `pricing-rulebook/docs/handbooks/pricing/methodology.md`'s split: a
  "Phase-1 proposal checklist" section and a "Phase-2 record checklist"
  section, each listing the charter's required components as worked
  guidance (the reasoning a regex can't check — e.g. how to judge
  "forbidden manipulation" for a logo, how to decide an asset genuinely
  has no imagery-style dimension) — restating the gate's mechanical floor
  in one line per item, then explaining the judgment behind it. This
  handbook is new prose written for this proposal's own design, not a
  copy of pricing's content.

## What is out of scope

- Actually writing `brand-design/hooks/methodology-gate.sh`,
  `hooks.json`'s new `PreToolUse` entry, `directive.sh`'s deepened
  strings, any `tests/` file, or `docs/handbooks/brand-design/
  methodology.md` — phase 2 only, after Approve.
- Writing `docs/issue-10/reports/brand-design.md` (the phase-2 record
  file) — off limits this phase.
- Building state-tracking machinery (lock files, ordering gates) — this
  proposal's explicit recommendation is not to build it (see (b)), but the
  decision is named for the approver rather than silently foreclosed.
- Choosing repo-root `tests/` vs. colocated `brand-design/hooks/tests/` is
  recommended (colocated) but left as an approver-visible choice, not
  silently pre-decided as unchangeable.
- Any change to `warrant-hunter`, `record-fields-gate.sh`, or any other
  core-canon-referenced gate.
- Any change to `ux-engineering`'s plugin or the `HAND_OFF` boundary
  itself.

## How this will be judged

- `docs/issue-10/reports/brand-design/survey.md` and
  `docs/issue-10/reports/brand-design/scout-brief.md` exist, cite real
  internal file paths (not external URLs — internal-canon-reuse mode is
  stated explicitly in scout-brief.md), and state must-bes/gap/adopt/skip
  per this repo's scouting convention.
- This proposal file exists at `docs/issue-10/proposals/
  2026-07-31-brand-design-directive-hardening.md` with frontmatter
  `subject: issue-10`, `role: brand-design`, `loop_state: scope-proposed`.
- Every design element in (a)–(d) traces to either a cited issue-1 charter
  section (methodology content) or a cited pricing-rulebook/
  implementation-rulebook file path (gate-construction pattern) — no
  canon text is duplicated verbatim in this file.
- The state-tracking question and the tests-location question are each
  named as an explicit open decision for the approver, not silently
  resolved.
- No file outside `docs/issue-10/**` is modified by this PR.
- No file under `src/` or `test/` is created or modified by this PR (none
  exist in this rulebook's tree; this proposal does not introduce them).
