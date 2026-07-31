---
subject: issue-10
role: brand-design
loop_state: scope-proposed
---

# Scout brief — issue-10 (internal-canon-reuse scouting mode)

**Scouting mode used: internal-canon-reuse, not external web research.**
Issue #10 itself names the exemplar (`pricing-rulebook`'s
`methodology-gate.sh`) and the rigor bar (`implementation-rulebook`'s hook
machine) — the canon this repo's sibling rulebooks already built IS the
exemplar corpus for this task, so this scouting pass reads that internal
prior art directly (file paths cited below) instead of running a live web
search. No claim in this brief is sourced from memory of general
practice; every must-be below is a literal file this session read on this
machine, in full, per the survey at
`docs/issue-10/reports/brand-design/survey.md`.

## Must-bes (what the reference hook machine treats as non-negotiable)

1. **Directive text carries the phase split and explicit prohibitions,
   not a one-line summary.** `implementation-rulebook/coding/hooks/
   directive.sh`'s `USE_WHEN`/`PRODUCES` strings are multi-paragraph,
   naming phase-1 vs phase-2 behavior separately and stating named
   prohibitions verbatim ("SCOPE-EXCEEDED RULE", "no self-review loops,
   no re-reading finished units"). A directive that only names *what* is
   produced, with no *how/when/forbidden* content, is the shallow form
   issue-10 is asking brand-design to move past.
2. **A methodology gate is scoped to the role's own write surfaces only,
   by regex, and denies fail-closed when it cannot determine resulting
   content.** `pricing/hooks/methodology-gate.sh` matches exactly
   `docs/issue-<n>/proposals/*pricing*.md` and `docs/issue-<n>/reports/
   pricing.md` — nothing else — and exits 0 (pass-through, "not my
   business") for any write outside those two patterns. It resolves
   Write/Edit/MultiEdit's *resulting* text before checking, and denies if
   it can't (e.g. an Edit whose `old_string` doesn't match current
   content).
3. **A methodology gate checks presence, not correctness — substring/
   regex floor, with a paired handbook carrying the judgment layer.**
   `pricing/hooks/methodology-gate.sh`'s own header says it enforces "the
   mechanical minimum"; `docs/handbooks/pricing/methodology.md` is
   explicitly "the reasoning behind each line." The gate never tries to
   verify a WCAG contrast number is *correct*, only that a labeled number
   / named element is *present*.
4. **Every gate is fail-closed on malformed input by construction**: a
   `trap __fc EXIT` at the very top of the file (before any `set`/
   `source`) forces any abnormal exit code to 2 (deny), and the Python
   judge body is wrapped in `try/except` that also forces exit 2 on any
   internal error. This pattern is identical across
   `coding-progress-gate.sh`, `hunt-guard.sh`, `methodology-gate.sh`, and
   core's `record-fields-gate.sh` — it is the load-bearing convention,
   not incidental.
5. **State-tracking (when the methodology has an ordering constraint) is
   file-based and maintained by a *different* hook than the one that
   reads it.** `hunt-guard.sh` (a `PreToolUse` gate) only *reads*
   `.warrant-hunt.lock`/`.warrant-hunt.count`; `hunt-state.sh` (wired to
   `SessionStart`/`SubagentStop`) is what writes/clears them. Similarly,
   `coding-progress-gate.sh` reads ordering state (verify.md's
   `loop_state` + `resolved_findings` cross-reference) that a *different*
   role (verify) writes — the gate never invents the state, it reads a
   record another party already produces.
6. **Gate tests are real subprocess runs against synthetic JSON payloads
   in a throwaway git repo, asserting an exit-code contract (0=allow,
   2=deny, anything else=internal-error/FAIL), not unit tests of internal
   functions.** `tests/run-gate-tests.sh` builds one `run()`/`trailergate()`
   /`progress()` helper per gate shape, each spinning up
   `mktemp -d && git init`, piping a synthetic tool-call JSON on stdin,
   and comparing `want` vs the mapped exit code. Case names are short and
   declarative (`record-complete`, `commit-no-trailer`,
   `blocking-finding-unresolved`).
7. **Canon reference discipline is universal**: every reference-rulebook
   gate resolves `CLAUDE_PLUGIN_ROOT_CORE`/`CORE_PLUGIN_ROOT` against a
   sibling `core` install rather than vendoring core logic; local
   role-specific gates (like `methodology-gate.sh`) are original to that
   role's own plugin tree, not copies of a core file — they *sit next to*
   the referenced core canon (`record-fields-gate.sh` stays referenced;
   `methodology-gate.sh` is additive and local because it is
   role-specific, not core-generic).

## Gap line (brand-design today vs. the must-bes above)

| Must-be | brand-design/hooks today |
|---|---|
| 1. Multi-paragraph directive w/ explicit phase split + prohibitions | `directive.sh`'s `PRODUCES` is one long sentence (deep in *content* since issue-9, but a single line — no phase-1/phase-2 split, no named 금지사항 list, no judgment-criteria prose) |
| 2. Role-scoped methodology `PreToolUse` gate | None — `hooks.json` registers only `SessionStart` → `directive.sh`; no `PreToolUse` entry exists at all |
| 3. Substring floor + paired handbook | No `docs/handbooks/` directory exists in this repo |
| 4. Fail-closed trap-at-top convention | N/A — no gate script exists yet to apply it to |
| 5. File-based state tracking for ordering constraints | N/A — brand-design's adopted methodology (issue-1 charter) is a single-pass per-asset check (brand guide entry → asset spec → consistency check), not a multi-turn ordering like coding/verify's finding-resolution loop; whether this needs state tracking at all is a judgment call this proposal must make explicitly (see proposal, methodology-gate design) |
| 6. Real-subprocess gate tests, exit-code contract | No `tests/` directory exists under `brand-design/hooks/` |
| 7. Canon-reference discipline | Already clean (issue-5's `stub-check.sh` reclaim); nothing to fix here — a new local `methodology-gate.sh` would be additive-local (role-specific), matching pricing's own precedent, not a canon violation |

## Adopt

- **Directive deepening in the `implementation-rulebook`/`coding/hooks/
  directive.sh` shape**: multi-line heredoc-style strings per phase, each
  ending in named prohibitions and judgment criteria, sourced from the
  already-approved issue-1 charter content (no new methodology invented,
  only its existing adopted rules restated as executable-level
  directive text).
- **A `brand-design/hooks/methodology-gate.sh` modeled directly on
  `pricing/hooks/methodology-gate.sh`**: same `Write|Edit|MultiEdit`
  matcher, same two-regex write-surface scoping
  (`docs/issue-<n>/proposals/*brand-design*.md` and `docs/issue-<n>/
  reports/brand-design.md`), same resulting-content resolution for
  Write/Edit/MultiEdit, same fail-closed trap-at-top, same kill-switch
  convention (e.g. `BRAND_DESIGN_METHODOLOGY_GATE_OFF=1`). Required
  elements to check are brand-design's own (from the issue-1 charter),
  not pricing's six — see proposal for the exact list.
- **A paired `docs/handbooks/brand-design/methodology.md`** in the
  `docs/handbooks/pricing/methodology.md` shape: gate = mechanical floor,
  handbook = reasoning + judgment material (e.g. how to judge whether a
  logo variant is "forbidden manipulation", not just that the field is
  present).
- **`tests/run-gate-tests.sh`-shape gate tests**: one repo-root `tests/`
  harness, real subprocess invocation, synthetic JSON payload, exit-code
  contract, named allow/deny cases — adapted to brand-design's own gate
  and fields, not implementation's.
- **Fail-closed `trap __fc EXIT` at the top of any new script** — copied
  as a *pattern*, not as literal text lifted from another rulebook's file
  (the pattern is a few lines of idiomatic bash any script author writes
  fresh; this is not a canon-manifest-listed core file, so nothing in
  `canon-scripts.md`'s reference-only rule applies to it, but originality
  of the specific script text is still required by this issue's own "no
  duplication of canon text" instruction).

## Skip

- **State-tracking machinery for an ordering constraint** — the
  `coding/verify` finding-resolution loop and `hunt-guard`/`hunt-state`
  lock-file pattern exist because those roles' methodologies have a real
  multi-turn ordering constraint (a blocking finding must be resolved
  before the *next* commit; a hunter must finish before the *next*
  dispatch). brand-design's adopted methodology (issue-1 charter) is a
  single-pass per-asset checklist with no cross-turn ordering dependency
  — there is no "step 2 cannot start until step 1's state file says so"
  requirement in the adopted charter. Building lock-file state tracking
  here would be inventing a constraint the approved methodology doesn't
  have. The proposal names this explicitly as a design decision (adopt
  substance-ordering via the gate's *field presence* check instead of a
  cross-turn state file), rather than silently skipping the issue's
  "if warranted" state-tracking ask.
- **hunt-guard/hunt-state's Agent/Task-dispatch cadence machinery** — this
  exists specifically to bound `warrant-hunter` re-dispatch cost, a
  concern proper to roles that dispatch that specific subagent
  (implementation-rulebook's `coding`). brand-design's issue-1 charter
  does not adopt a warrant-hunter cadence requirement; nothing in this
  role's approved methodology calls for bounding a repeated subagent
  dispatch, so this pattern is not adopted.
- **Pricing's exact six-element vocabulary** (method/family/inputs/
  gate-check/labeled-numbers/residual) — that vocabulary is pricing's own
  domain methodology (Van Westendorp/conjoint literature), not
  brand-design's. Only the *gate-construction pattern* (regex-scoped
  write surface, resulting-content resolution, substring-presence checks,
  fail-closed) is adopted; the *field list* is brand-design's own, drawn
  from the already-approved issue-1 charter (brand guide entry sub-fields,
  asset spec, consistency-check-with-WCAG, design-system source paths).

## Adopt/skip summary tied back to issue-10's four asks

1. Directive deepening → adopt (implementation-rulebook shape).
2. Methodology gate + state tracking → adopt the gate (pricing shape);
   skip cross-turn state-file tracking (no ordering constraint exists in
   the adopted charter to enforce that way) — the gate's own
   field-presence check is the state check for this role.
3. Gate tests → adopt (implementation-rulebook's `run-gate-tests.sh`
   shape, repo-root `tests/`).
4. Agents/checklists → the issue-1 charter's "required components, per
   deliverable" list is already checklist-shaped; adopt formalizing it as
   the paired handbook's checklist (pricing's `methodology.md` shape),
   not a new subagent — brand-design's methodology has no repeated
   multi-step procedure that needs an `agents/` definition (no
   warrant-hunter-equivalent cadence to bound), so `agents/` is
   deliberately not proposed. This is a judgment call the proposal states
   explicitly rather than silently omitting.
