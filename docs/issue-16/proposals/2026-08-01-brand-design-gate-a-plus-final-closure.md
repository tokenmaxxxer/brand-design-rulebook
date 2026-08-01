# Proposal: brand-design gate-house A+ final closure (issue-16)

Phase-1 design only. No code changes in this PR — phase-2 opens on an
approvers.md Approve per contract v3 s19. Full findings:
`docs/issue-16/reports/brand-design/survey.md`.

## Kapferer scope note

Physique-facet only, same as issue-13's proposal: pure implementation-
hygiene remediation of the role's own gate tooling, referencing already-
landed upstream core fixes. No Personality/Culture/Relationship/
Reflection/Self-image judgment call arises.

## Precondition check

core issue #75 (`52bdc15`, PR #77) and on-the-record #182 are both landed,
per the issue's own gate — verified directly for #75 (survey.md); #182
taken on the issue's word (its repo is outside this role's read scope).

## Design 1: adopt core #75's guarded source line in all four gates

Each `brand-design-*/hooks/methodology-gate.sh` line 2 changes from:

```bash
. "${CLAUDE_PLUGIN_ROOT_CORE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd -P)}/hooks/lib/gate-lib.sh"
```

to the current `gate-lib.sh` usage-comment form, verbatim (reference-
adopt, no local reinvention):

```bash
. "${CLAUDE_PLUGIN_ROOT_CORE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd -P)}/hooks/lib/gate-lib.sh" || { echo "<gate-name>.sh: cannot source gate-lib.sh" >&2; exit 2; }
```

(`<gate-name>` substituted per-file, matching each gate's own filename per
the pattern core's own seven gates use.) This closes defect 1: fail-
closed instead of fail-open when core is unreachable. No other line in
any gate changes for this fix.

## Design 2: fix `system-handoff`'s N2 path-token defect

`brand-design-system-handoff/hooks/methodology-gate.sh`'s `PATH_TOKEN_RE`
currently accepts any bare `word/word`-shaped token as a design-system
source path:

```python
PATH_TOKEN_RE = re.compile(r'`?([\w][\w./-]*\/[\w][\w./-]*)`?')
```

Apply the same fix issue-13 already applied to `guide-and-spec`'s
`asset_spec_present` (survey.md, defect 2): require a real path signal,
not a bare slash-joined token pair. Since this check's domain is repo
paths (not asset extensions/hex values), the fix is a file-extension-
agnostic but still-anchored path shape: require the token to either (a)
start with a path-shaped prefix (`docs/`, `src/`, `assets/`, or contain a
`.` in the final segment — i.e. a real filename-shaped tail), or (b) be
explicitly fenced as inline code (an existing backtick-wrapped token, `` `path/like/this` ``)
combined with containing at least one `/` **and** at least one `.` in the
segment after the last `/` — mirroring `guide-and-spec`'s "provable only
by extension match or explicit value" principle applied to generic repo
paths rather than asset files. Concretely:

```python
PATH_TOKEN_RE = re.compile(
    r'`?((?:docs|src|assets|core|brand-design(?:-[\w-]+)?)/[\w./-]*\.[\w]+|`[\w][\w./-]*/[\w][\w./-]*\.[\w]+`)`?'
)
```

i.e. drop the bare `\w+/\w+` acceptance entirely and require a dotted
extension on the final path segment, exactly as `guide-and-spec` already
requires for asset paths. A prose token like `pass/fail` or `true/false`
has no dotted final segment and no longer matches. Every existing
allow-case fixture in `system-handoff`'s own test suite already uses
extensioned paths (survey.md confirms no test relies on the bare-token
fallback), so this is a false-positive-only tightening with no known
regression to the plugin's own test suite.

## Design 3: make `replace_all` tests mutation-discriminating in the two
non-discriminating plugins

`brand-design-guide-and-spec` and `brand-design-system-handoff`
(survey.md, defect 3) each get their existing replace_all fixture
content adjusted so `replace_all:false` and `replace_all:true` produce
**different** allow/deny outcomes, following the pattern
`kapferer-scope-guard` and `wcag-consistency` already use correctly:

- `guide-and-spec`'s group-1 `EDIT_START` fixture changes so the
  asset-spec paragraph requires **both** placeholder occurrences resolved
  to satisfy the (now section/adjacency-scoped) check — e.g. make the
  paragraph's provable-value requirement depend on a token that only
  appears validly after both replacements land (mirroring
  `kapferer-scope-guard`'s existing two-placeholder-in-one-paragraph
  fixture shape). The existing `replace_all:false` case's expected
  outcome flips from `allow` to `deny`, and a code comment states why
  (first-occurrence-only leaves the paragraph's requirement unmet).
- `system-handoff`'s group-1/group-2 fixtures get the same treatment
  against its design-system-source-paths paragraph, using a real
  extensioned path (post-Design-2 fix) that must appear in full only
  after all occurrences are resolved.

This removes the "3/4 허수" residual: all four plugins' replace_all test
groups become behavior-outcome-discriminating (a reverted or broken
`gate_reconstruct_write` call would flip at least one case's expected
result), not just outcome-shaped padding.

## Design 4: matcher/code coverage invariant — hold, document, add a guard
test (issue requirement 2)

survey.md's defect-4 finding: today's matcher (`Write|Edit|MultiEdit`)
and each gate's tested/advertised branches already agree — no gate
branches on `Bash` or any other tool the matcher doesn't route. This
proposal adds no new `Bash`-policing behavior (issue-13 explicitly kept
that out of scope, and issue-16 doesn't ask for new policing surface
either — only "정합"). What's added: a one-line static assertion in each
plugin's `hooks/tests/methodology-gate-tests.sh`, run once at suite
start, that greps its own `hooks.json` matcher and its own
`methodology-gate.sh` for any tool-name literal not covered by the
matcher — failing the suite loudly if a future edit adds a tool branch
without updating the matcher (or vice versa), rather than leaving the
invariant to be re-verified by hand each time. This is the durable form
of "정합" the issue asks for: a regression guard, not a one-time manual
check.

## Design 5: README fix (defect 5)

`README.md`'s Layout section line:
```
- `brand-design/hooks/hooks.json` — SessionStart + PreToolUse wiring
```
becomes:
```
- `brand-design/hooks/hooks.json` — SessionStart wiring only (role
  directive); each `brand-design-*/hooks/hooks.json` carries its own
  PreToolUse gate wiring — see below.
```
No other README/manifest change: survey.md confirms ghost-file/old-
role-name requirement 4 is already satisfied from issue-13's landing.

## Compliance evidence (issue requirement 3/4 exit criterion)

Phase-2's record cites, per the same evidence form issue-13 used:
- `core/hooks/tests/compliance-check.sh brand-design-*/hooks` clean
  against all four plugins, now including core #75's new unguarded-source
  detection rule (this is the rule Design 1 makes all four gates pass).
- `bash hooks/tests/methodology-gate-tests.sh` green in all four plugin
  directories, including: the missing-core case (core #75's new
  mandatory 7th group — `CLAUDE_PLUGIN_ROOT_CORE` pointed at a
  nonexistent path with no valid relative fallback, asserting deny/exit 2)
  added to each of the four suites; the corrected N2 fixture-driven
  replace_all cases (Design 3); and the new matcher/coverage static
  assertion (Design 4).

## Out of scope for this role (HAND_OFF boundary, unaffected)

No new Bash-write policing behavior (Design 4 is a static consistency
guard, not new gating logic). No change to `core`'s own canon files
(read-only reference). This proposal only touches the four
`brand-design-*/hooks/methodology-gate.sh`, the four
`brand-design-*/hooks/tests/methodology-gate-tests.sh`, and the root
`README.md`.
