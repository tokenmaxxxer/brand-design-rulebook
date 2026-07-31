---
subject: issue-10
role: brand-design
loop_state: scope-proposed
---

# Survey — issue-10 (directive hardening + methodology gate, brand-design)

Phase-1 survey only. No hook, gate, or plugin file is touched by this
document.

## Issue text (paraphrased)

**Issue #10** ("플러그인 심화: 채택 방법론을 직접 강제 장치로 구현
(implementation-rulebook 수준)"): the prior maturation round (issue-1)
adopted a domain methodology for brand-design, but it only landed as a
one-line `PRODUCES` summary in `brand-design/hooks/directive.sh` plus
prose docs — there is no mechanical enforcement. `implementation-rulebook`
enforces its own norms with 400+ lines of hook machinery (progress gates,
state tracking); this rulebook has none. The issue asks phase-1 (design
only) to cover: (1) directive deepening — concrete stages/judgment
criteria/prohibitions per facet, not a one-line summary; (2) a methodology
gate — a `PreToolUse` gate that mechanically checks the approved
`PRODUCES` elements are present on writes to this role's proposal/record
surfaces, referencing `pricing-rulebook`'s `methodology-gate.sh` as the
exemplar, plus state-tracking if the methodology has an ordering
constraint (survey → evidence → adoption); (3) gate tests — pass/fail
cases under the repo's `tests/`; (4) agents/checklists if the methodology
needs a repeated procedure. Constraint: canon scripts are referenced only,
never copied (core `docs/handbooks/canon-scripts.md`); role boundaries and
`write_scope` are unchanged; the prior maturation issue's adoption
rationale (issue-1) is the norm source.

**Issue #1** ("룰북 성숙화: brand-design 도메인 방법론 조사 기반 제안서·
산출물 규범 수립", CLOSED): the issue this repo's own methodology charter
came from. Phase 1 asked for a broad survey of brand-design methodology
and a proposal for (a) this rulebook's own phase-1 proposal-doc norm, (b)
this role's phase-2 deliverable norm, (c) adoption justification tied to
the `YOU_DECIDE` mandate, (d) a plugin-reflection plan. Phase 2 asked for
reflecting the approved charter into `directive.sh`/record fields.

**Issue #9** (MERGED): phase-2 delivery of issue-1 — reflected the
approved charter into `brand-design/hooks/directive.sh`'s `PRODUCES` line
(expanded the four nouns — brand guide entry / asset spec / consistency
check / design-system source paths — into their required sub-fields) and
added `docs/issue-1/reports/brand-design.md`. Explicitly left one item
open: whether core's generic `record-fields-gate.sh` (§20 shape only) is
sufficient, or a role-specific gate should be proposed — flagged for a
future approver, not resolved. **This is exactly the open item issue-10
now asks to close** (item 3(b) in the issue-9 record's "Open findings").

**Issue #8** (MERGED): phase-1 proposal of issue-1 — the methodology
charter and scout-brief that back everything above.

## Current plugin/rulebook state (this repo)

- `brand-design/.claude-plugin/plugin.json` — plugin metadata; depends on
  core + warrant plugins from `tokenmaxxxer-core`, installed alongside.
- `brand-design/hooks/directive.sh` — a single `core_role_directive` call
  with four strings (`YOU_DECIDE`, `USE_WHEN`, `PRODUCES`, `HAND_OFF`).
  `PRODUCES` (post-issue-9) reads: "brand guide entry (logo usage rule if
  applicable, exact color values, typography role, voice/tone note if copy
  present, imagery style note if applicable, do's/don'ts), asset spec
  (exact values applied + file formats/paths), consistency check vs
  existing guide (checklist pass/fail incl. WCAG 4.5:1/3:1 contrast
  result), design-system source paths". This is prose only — nothing
  mechanically checks a written record actually contains these fields
  beyond core's generic §20 shape (what/why/upstream-basis/loop_state/
  open-findings).
- `brand-design/hooks/hooks.json` — registers exactly one hook:
  `SessionStart` → `directive.sh`. No `PreToolUse` gate exists in this
  plugin at all.
- No `brand-design/hooks/tests/` directory exists (the one vendored
  `stub-check.sh` copy that used to live there was removed in issue-5;
  confirmed absent by `find brand-design -type f`).
- No `agents/` directory, no `docs/handbooks/` directory exist in this
  repo yet.
- `docs/specs/approvers.md` lists a single account (`JiwonJung94`) —
  single-account mode: that account's issue comment `APPROVE
  issue-<n>/<role>` opens phase 2, per contract v3 §19 (already used this
  way for issue-1's phase-2, per the issue-9 record).

## Norm source: issue-1's methodology charter (this rulebook's adopted methodology)

`docs/issue-1/proposals/2026-07-31-brand-design-methodology-charter.md`
and `docs/issue-1/reports/brand-design/scout-brief.md` establish the
adopted methodology this issue must mechanize:

- Brand-style-guide structure (logo/color/typography/voice/imagery/
  do's-don'ts) as the required components of a "brand guide entry".
- Atomic Design's "define once, compose everywhere" as the justification
  for the `HAND_OFF → ux-engineering` boundary (design-system source
  paths).
- WCAG 2 contrast thresholds (4.5:1 AA normal text / 3:1 AA large text) as
  an explicit, numeric pass/fail requirement inside the "consistency check
  vs existing guide" deliverable.
- Kapferer's Brand Identity Prism, Physique facet only, as a scoping lens
  (not a deliverable template) — the other five facets are out of scope.
- A lightweight heuristic-checklist shape (named items, pass/fail,
  consolidated verdict) for the consistency-check deliverable.
- `docs/issue-1/reports/brand-design.md` (the phase-2 record from issue-9)
  is the reflected, landed form of the same charter — confirms the
  `PRODUCES` sub-fields above are what actually shipped into
  `directive.sh`.

## Reference: implementation-rulebook's hook-machine (the cited rigor bar)

Found at `/home/jwjung/tokenmaxxxer/rulebooks/implementation-rulebook`
(sibling checkout on this machine, not part of this repo — referenced by
path only, no content copied into this repo).

- `coding/hooks/directive.sh` — multi-paragraph, multi-line `YOU_DECIDE`/
  `USE_WHEN`/`PRODUCES`/`HAND_OFF` strings (heredoc-style `$'...'`
  strings), not one-line summaries: phase-1 vs phase-2 behavior, concrete
  prohibitions (SCOPE-EXCEEDED RULE: "never widen mid-build, never pause
  to ask mid-build"), document-placement doctrine ladder, hunt cadence
  requirements.
- `coding/hooks/coding-progress-gate.sh` — a `PreToolUse` gate matched on
  `Bash` (`git commit`) that fail-closed-parses the target subject's
  `verify.md` for inline `finding` blocks with `severity: blocking` /
  `addressed_to: coding`, and refuses the commit unless the coding
  record's own `resolved_findings` entry names the finder path + a commit
  sha AND the finder's `loop_state` is `cleared`. This is the ordering/
  state-tracking mechanism issue-10 alludes to ("조사→근거→채택" style
  sequencing enforced by state, not by prose).
- `coding/hooks/hunt-guard.sh` + `hunt-state.sh` — a second `PreToolUse`
  gate (matched on `Agent|Task`) enforcing a single-flight lock and a
  session dispatch cap for the `warrant-hunter` subagent, with state files
  (`.warrant-hunt.lock`, `.warrant-hunt.count`) maintained by
  `SessionStart`/`SubagentStop` hooks (`state.sh`). This is the
  agents/checklist-cadence enforcement pattern (item 4 of issue-10).
- `coding/hooks/hooks.json` — wires `SessionStart` (directive + state
  reset), `PreToolUse` × 2 (progress gate on Bash, hunt guard on
  Agent/Task).
- `tests/run-gate-tests.sh` — a real-subprocess test harness: spins up a
  throwaway git repo per case, feeds a synthetic JSON tool-call payload on
  stdin to the gate script under test, reads its exit code (0 = allow,
  2 = deny, anything else = internal-error), and asserts want vs. got.
  Named cases (`record-complete`, `record-empty`, `foreign-path`,
  `commit-no-trailer`, `commit-with-trailer`, `blocking-finding-
  unresolved`, `no-verify-findings`) mix allow and deny fixtures per gate.
  This is the exact test shape issue-10 asks item 3 to match.

## Reference: pricing-rulebook's methodology-gate.sh (the exact exemplar named in issue-10)

Found at `/home/jwjung/tokenmaxxxer/rulebooks/pricing-rulebook` (sibling
checkout, referenced by path only). This is the closest existing analogue
to what brand-design needs — another role, same repo shape
(`docs/issue-1/proposals/methodology-norms.md` +
`docs/handbooks/pricing/methodology.md`), that already built exactly the
gate issue-10 asks for:

- `pricing/hooks/methodology-gate.sh` — a `PreToolUse` gate matched on
  `Write|Edit|MultiEdit`. Targets exactly two write surfaces by regex:
  `docs/issue-<n>/proposals/*pricing*.md` (phase-1) and
  `docs/issue-<n>/reports/pricing.md` (phase-2 record) — i.e. this role's
  own `write_scope`, nothing else. Resolves the *resulting* content for
  Write (full `content`), Edit (`old_string`→`new_string` applied to
  current file text) and MultiEdit (each edit applied in sequence);
  denies outright if the resulting content can't be determined from the
  tool input. Then does substring/regex presence checks (not a full
  parser) for six required elements named in
  `docs/issue-1/proposals/methodology-norms.md`: method named (or an
  explicit early-exit), conjoint family named when conjoint language
  appears, inputs-needed stated, a gate-check result present, any numeric
  verdict carrying a label, and a residual (what-this-cannot-answer)
  list. Fail-closed trap-at-top (`__fc` EXIT trap forcing exit 2 on any
  non-0/non-2 termination) — identical pattern to core's
  `record-fields-gate.sh`. Kill switch:
  `PRICING_METHODOLOGY_GATE_OFF=1`.
- `pricing/hooks/hooks.json` — `SessionStart` → directive, `PreToolUse`
  (`Write|Edit|MultiEdit`) → `methodology-gate.sh`. No Bash-matched gate;
  pricing's methodology has no ordering constraint that needs state
  tracking (single-pass verdict), unlike coding's finding-resolution
  ordering.
- `docs/handbooks/pricing/methodology.md` — a worked-guidance handbook:
  states the gate enforces "the mechanical minimum," the handbook is "the
  reasoning behind each line" — i.e. the gate is deliberately a *substring
  floor*, and the handbook carries the judgment-call material a regex
  can't check (family taxonomy disputes, named external sources,
  overclaiming risk). This is the split issue-10's directive-deepening
  item and methodology-gate item should mirror: directive/handbook carry
  judgment, gate carries the mechanical floor.

## Core canon consulted (referenced only, not copied)

- `core/hooks/record-fields-gate.sh` (`tokenmaxxxer-core/core/hooks/`) —
  the generic §20 gate already active on any role's own record via
  `CLAUDE_ROLE`; brand-design already benefits from this (any role's
  `docs/issue-<n>/reports/<role>.md` write is checked for what-was-done/
  why/upstream-basis/loop_state/open-findings). A role-specific gate is
  additive on top of this, never a replacement.
- `docs/handbooks/canon-scripts.md` (core repo) — "canon scripts are
  referenced, never copied"; any script under `core/hooks/` or
  `core/hooks/tests/` must be invoked via a path resolved against the core
  plugin's install root, never vendored a second time. `core/hooks/tests/
  canon-manifest.txt` lists the files this is enforced against
  mechanically via `stub-check.sh` (already run clean against
  `brand-design/hooks` per issue-5's record).
- `docs/handbooks/role-gates-tests.md` (core repo) — documents the
  sanctioned canon-invocation form and the real-subprocess test harness
  convention used by `run-gate-tests.sh`-style scripts.

## Gap line

- **Missing vs. the cited rigor bar:** no `PreToolUse` gate of any kind in
  `brand-design/hooks/hooks.json`; `directive.sh`'s `PRODUCES` line is a
  single unstructured sentence (deep in content since issue-9, but still
  one line, no phase-1-vs-phase-2 split, no explicit prohibitions/금지사항
  section); no `tests/` directory; no `agents/` or checklist assets.
- **Already met:** the norm source itself (issue-1's charter) is already
  approved and landed — this issue does not need to re-derive *what* the
  methodology requires, only *how* to mechanically enforce what issue-1
  already adopted. `stub-check.sh` canon-reference discipline is already
  clean (issue-5). The single-account approvers.md / contract v3 §19 flow
  that will gate phase 2 is already proven (issue-1/issue-9's `APPROVE`
  precedent).
- **Open item this issue must resolve:** issue-9's own record left open
  "core's generic record-fields-gate vs a role-specific substring check"
  — issue-10 is effectively the vehicle that decides this, via the
  design proposed in `docs/issue-10/proposals/`.

## Sources (internal canon, not external web)

- `docs/specs/approvers.md` (this repo)
- `brand-design/.claude-plugin/plugin.json`, `brand-design/hooks/
  directive.sh`, `brand-design/hooks/hooks.json` (this repo)
- `docs/issue-1/proposals/2026-07-31-brand-design-methodology-charter.md`,
  `docs/issue-1/reports/brand-design/scout-brief.md`, `docs/issue-1/
  reports/brand-design.md` (this repo)
- `docs/issue-5/proposals/2026-07-31-stub-check-canon-reclaim.md`,
  `docs/issue-5/reports/implementation.md` (this repo)
- `/home/jwjung/tokenmaxxxer/rulebooks/implementation-rulebook/coding/
  hooks/{directive.sh,coding-progress-gate.sh,hunt-guard.sh,hunt-state.sh,
  hooks.json}`, `/home/jwjung/tokenmaxxxer/rulebooks/implementation-
  rulebook/tests/run-gate-tests.sh` (sibling checkout, referenced by path)
- `/home/jwjung/tokenmaxxxer/rulebooks/pricing-rulebook/pricing/hooks/
  {directive.sh,methodology-gate.sh,hooks.json}`, `/home/jwjung/
  tokenmaxxxer/rulebooks/pricing-rulebook/docs/handbooks/pricing/
  methodology.md` (sibling checkout, referenced by path)
- `/home/jwjung/tokenmaxxxer/tokenmaxxxer-core/core/hooks/
  record-fields-gate.sh`, `/home/jwjung/tokenmaxxxer/tokenmaxxxer-core/
  docs/handbooks/canon-scripts.md` (sibling checkout, referenced by path)
