# issue-16 phase-2 record (brand-design gate-house A+ final closure)

loop_state: landed

## what was done

Delivered the approved proposal
(`docs/issue-16/proposals/2026-08-01-brand-design-gate-a-plus-final-closure.md`)
in full, across all four `brand-design-*/hooks/methodology-gate.sh` +
`hooks/tests/methodology-gate-tests.sh`, plus the root `README.md`:

1. **Guarded `gate-lib.sh` source (Design 1)** — all four gates' line-2
   source statement now carries the `|| { echo "methodology-gate.sh:
   cannot source gate-lib.sh" >&2; exit 2; }` fail-closed guard, verbatim
   per core #75's usage form. Fail-open-on-missing-core (survey defect 1)
   is closed in all four.
2. **`system-handoff` N2 fix (Design 2)** — `PATH_TOKEN_RE` replaced with
   the extensioned-path-anchored regex (proposal Design 2, verbatim).
   Bare `word/word` prose tokens (`pass/fail`, `true/false`) no longer
   match as design-system source paths. This plugin's own test-suite
   fixture paths were adjusted to the covered prefix set (`src/...`)
   where the old `ux-engineering/...` paths fell outside the new prefix
   list.
3. **`replace_all` mutation-discrimination (Design 3)** —
   `guide-and-spec` and `system-handoff` fixtures rebuilt so
   `replace_all:false` now denies (first-occurrence-only reconstruction
   leaves the paragraph's provable-value requirement unmet) while
   `replace_all:true` still allows, mirroring
   `kapferer-scope-guard`/`wcag-consistency`'s existing discriminating
   pattern. All four plugins' replace_all groups are now real
   mutation-sensitive regression guards — the "3/4 허수" residual is
   closed.
4. **Matcher/code coverage invariant, held + guarded (Design 4)** — added
   a one-time static assertion at the start of each of the four
   `hooks/tests/methodology-gate-tests.sh`, comparing each plugin's own
   `hooks.json` PreToolUse matcher against its own gate script's
   tool-name literals. All four currently report full agreement
   (`Write|Edit|MultiEdit` covers every literal branched on); the
   assertion is a durable regression guard against future drift, not a
   behavior change.
5. **README fix (Design 5)** — `README.md`'s Layout section corrected:
   `brand-design/hooks/hooks.json` now documented as SessionStart-only;
   each `brand-design-*/hooks/hooks.json`'s own PreToolUse wiring is
   noted as documented per-plugin below it.

Each of the four plugins also gained the mandatory 7th test-harness group
(core #75): `missing-core` — `CLAUDE_PLUGIN_ROOT_CORE` pointed at a
nonexistent path with no valid relative fallback, asserting deny/exit 2
rather than silent allow, proving the new Design-1 guard actually fires.

### Ghost files / old role names (issue requirement 4)

Re-checked: `grep -rn "warrant-hunter\|record-fields-gate\|trailer-gate\|
handbook-trigger-gate"` across all live `.md`/`.json` — every hit is
inside a historical `docs/issue-<n>/{proposals,reports}` document
recording past decisions, never a live README/manifest/plugin.json
reference or a vendored file. Requirement 4 was already satisfied as of
issue-13's landing (per survey.md) and remains so; defect 5 (the one live
misdescription found this round) is fixed above.

### Compliance evidence

```
$ bash hooks/tests/methodology-gate-tests.sh   (each of the four plugin dirs)
brand-design-guide-and-spec:        20 passed, 0 failed
brand-design-kapferer-scope-guard:  17 passed, 0 failed
brand-design-system-handoff:        19 passed, 0 failed
brand-design-wcag-consistency:      18 passed, 0 failed
(all four: 7/7 mandatory groups exercised, including missing-core)

$ bash <tokenmaxxxer-core issue-75 checkout>/hooks/tests/compliance-check.sh <plugin>/hooks
compliance-check: ok — brand-design-guide-and-spec/hooks/methodology-gate.sh
compliance-check: ok — brand-design-kapferer-scope-guard/hooks/methodology-gate.sh
compliance-check: ok — brand-design-system-handoff/hooks/methodology-gate.sh
compliance-check: ok — brand-design-wcag-consistency/hooks/methodology-gate.sh
```

Full-suite delivery status: **green** across all four plugins, including
the missing-core case; compliance-check clean against core #75's new
unguarded-source rule.

### Scope discipline

No new `Bash`-write policing behavior added (Design 4 stays a static
consistency guard, per the proposal's explicit HAND_OFF boundary). No
change to core's own canon files. Touched files: the four
`brand-design-*/hooks/methodology-gate.sh`, the four
`brand-design-*/hooks/tests/methodology-gate-tests.sh`, and the root
`README.md` — exactly the proposal's declared surface.

## why

Issue #16's 2026-08-01 재감사 found five residual defects against the
gate-house A+ bar: unguarded `gate-lib.sh` sourcing (fail-open on missing
core, all four gates), `system-handoff`'s unfixed "N2" bare-path-token
fallback, non-discriminating `replace_all` tests in two of four plugins
(mutation-verification failure), a matcher/code coverage invariant to
hold going forward, and a README misdescription of
`brand-design/hooks/hooks.json`. Two upstream preconditions
(`tokenmaxxxer-core` issue #75's guarded-source canon + compliance-check
rule; on-the-record #182's `CLAUDE_PLUGIN_ROOT_CORE` injection) were
required to land first, and had, per the approved phase-1 survey. This
record delivers the approved proposal's reference-adopt remediation
against that landed upstream contract, closing gate A+ for this role.

## upstream basis

- `docs/issue-16/proposals/2026-08-01-brand-design-gate-a-plus-final-closure.md`
  (this role's own approved phase-1 proposal)
- `docs/issue-16/reports/brand-design/survey.md` (this role's own phase-1
  current-state survey)
- tokenmaxxxer-core issue #75 (`52bdc15`/`f61d52f`, PR #77): guarded
  `gate-lib.sh` source-line canon form, `compliance-check.sh`'s new
  unguarded-source FAIL rule, `gate-lib.py`'s `gate_bash_write_targets`,
  and the mandatory 7th (`missing-core`) test-harness group, all landed
  and read directly from
  `/home/jwjung/.tokenmaxxxer/work/tokenmaxxxer-core-issue-75-implementation/core`.
- on-the-record #182 (`CLAUDE_PLUGIN_ROOT_CORE` injection in `spawn.py`):
  taken on the issue's own word, as the phase-1 survey already recorded
  (this role's read scope does not cover on-the-record's own repo).
- `brand-design-kapferer-scope-guard/hooks/tests/methodology-gate-tests.sh`
  and `brand-design-wcag-consistency/hooks/tests/methodology-gate-tests.sh`
  (their existing genuinely-discriminating `replace_all` fixtures),
  used as the structural template for fixing `guide-and-spec` and
  `system-handoff`'s non-discriminating fixtures.

## open findings

None outstanding for this issue's scope. All five named defects fixed,
full suite green (including the new missing-core case) in all four
plugins, compliance-check clean, ghost-file/old-role-name requirement
re-verified clean.
