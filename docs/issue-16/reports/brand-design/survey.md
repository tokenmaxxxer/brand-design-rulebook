# issue-16 phase-1 survey (brand-design gate-house A+ final closure)

Phase-1 only. Current-state facts, read from the live files in this repo
and from `tokenmaxxxer-core` (`/home/jwjung/tokenmaxxxer/tokenmaxxxer-core`,
`origin/main` @ `52bdc15`, core issue #75 landed).

## Scout-directive skip record

Skipped. Condition: spec leaves no open design decision — the issue names
four concrete, already-diagnosed defects and mandates "core #75의 확정
가드/규칙을 참조 적용" (reference-adopt core's already-landed fix, not
invent a new one). This is remediation against a fixed upstream contract,
not a product-shaped design choice; scouting an external field would not
change which gate-lib calls to make.

## Precondition check

- core issue #75 (`52bdc15ff0`, PR #77, merged): landed on
  `tokenmaxxxer-core` main. Confirmed by direct read of
  `core/hooks/lib/gate-lib.sh`, `core/hooks/lib/gate-lib.py`,
  `core/hooks/tests/compliance-check.sh`, and
  `docs/handbooks/gate-house-standard.md` (git show `52bdc15`).
  - `gate-lib.sh`'s usage comment now mandates an `||`-guarded source line:
    `. "$path" || { echo "<gate-name>.sh: cannot source gate-lib.sh" >&2; exit 2; }`.
  - `compliance-check.sh` gained a rule flagging `gate-lib\.sh"$` with no
    `\|\|` guard on the same line as a FAIL.
  - `gate-lib.py` gained `gate_bash_write_targets(command)`, a regex-token
    mirror (`[A-Za-z0-9_./~$-]+`) of the sh version, sh/py parity-tested
    upstream.
  - `gate-house-standard.md`'s "Standard test harness" is now **seven**
    mandatory case groups (was six): the new #7 is "gate-lib.sh sourced
    with `CLAUDE_PLUGIN_ROOT_CORE` pointed at a nonexistent path and no
    valid relative fallback — must assert deny (exit 2)."
- on-the-record #182 (`CLAUDE_PLUGIN_ROOT_CORE` injection in `spawn.py`):
  referenced by the issue as landed; not independently re-verified here
  (on-the-record's own repo is outside this role's read scope) — taken on
  the issue's word per contract, consistent with core #75's report
  language ("a marketplace install resolves this via
  `CLAUDE_PLUGIN_ROOT_CORE` set by the plugin host at runtime").

Both preconditions satisfied per the issue's own gate.

## Defect 1 (confirmed): unguarded `gate-lib.sh` source in all four gates

`grep -n 'gate-lib.sh"' brand-design-*/hooks/methodology-gate.sh` — all
four hits are the pre-issue-75 bare form:

```
. "${CLAUDE_PLUGIN_ROOT_CORE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd -P)}/hooks/lib/gate-lib.sh"
```

No `||` guard on any of the four. Under core's own `compliance-check.sh`
rule (issue-75), this is now a compliance-check FAIL for all four gates:
if core is unreachable (bad `CLAUDE_PLUGIN_ROOT_CORE`, missing sibling
checkout), the source fails silently, `gate_kill_switch_active` is
undefined, and every `gate_kill_switch_active ... || { exit 0; }` call
site reads the resulting "command not found" (exit 127) as the kill
switch being off — fail-open on missing core, the exact defect class
issue-75 fixed in core's own seven gates. This role's four gates never
picked up the fix.

## Defect 2 (confirmed, this is the issue's "N2"): `system-handoff` still
has the bare `\S+/\S+`-shaped path-token fallback

`brand-design-system-handoff/hooks/methodology-gate.sh` (design-system
source-paths check, NOT the same code path as
`brand-design-guide-and-spec`'s `asset_spec_present`, which issue-13
already fixed):

```python
PATH_TOKEN_RE = re.compile(r'`?([\w][\w./-]*\/[\w][\w./-]*)`?')
```

This matches any two `\w`-token halves joined by `/` — including
`pass/fail`, `true/false`, or any other non-path prose token shaped like
`word/word`. issue-13's remediation fixed this exact shape only inside
`guide-and-spec`'s `asset_spec_present`; `system-handoff`'s independent
design-system-source-paths label/paragraph check was never touched
(issue-13's scope was the four listed defects, and this token shape
inside `system-handoff` was not one of the six named there — it survived
as a live, undiagnosed instance of the same defect class until this
re-audit's "N2" finding).

`brand-design-kapferer-scope-guard` and `brand-design-wcag-consistency`
were checked for the same shape and do not use a bare-path fallback in
their own semantic checks (kapferer's is an acknowledgement-phrase
match, wcag's is a ratio/verdict-pairing match with no path token
concept) — this defect is `system-handoff`-only, confirming the issue's
naming of it as a single "N2" residual rather than a repeat-everywhere
defect.

## Defect 3 (confirmed): `replace_all` test groups are non-discriminating
in 3 of 4 plugins (mutation-verification failure)

All four `hooks/tests/methodology-gate-tests.sh` files carry a "group 1"
Edit-`replace_all` case and a "group 2" MultiEdit-mixed-`replace_all`
case, but the test harness (`report()`) only compares the gate's
allow/deny **outcome** — no test asserts the reconstructed text content
itself. That is sound only when the fixture is built so a broken
`replace_all` (first-occurrence-only) would flip the outcome. Read
against each plugin:

- `brand-design-kapferer-scope-guard` (lines 56-65): genuinely
  discriminating — the fixture requires **both** placeholder occurrences
  resolved for the label's paragraph check to pass, so first-occurrence-
  only reconstruction would still deny. A broken `replace_all` fails this
  test.
- `brand-design-wcag-consistency` (lines 66-81): genuinely discriminating
  — the MultiEdit-mixed case (b) asserts **deny**, and that deny only
  holds if the `replace_all:false` edit is honored as first-occurrence-
  only, leaving the second paragraph unresolved. A `replace_all` bug that
  ignores the flag (always full-replace, or always first-occurrence)
  flips this to allow, correctly failing the test.
- `brand-design-guide-and-spec` (lines 100-110): **not discriminating**.
  The file's own comment admits it: "replace_all:false still satisfies
  asset_spec_ok here because the gate only requires ONE
  extension/hex match somewhere in the label's paragraph... distinctness
  from replace_all:true is proven by ... own reconstructed-content
  assertion below" — but no reconstructed-content assertion exists
  anywhere in this file (confirmed by `grep -n
  "reconstruct\|assert_content\|diff \|EXPECTED"` across all four test
  files: zero hits for any content-diff assertion). Both the
  `replace_all:true` and `replace_all:false` cases assert `allow`; a gate
  that ignored `replace_all` entirely (always first-occurrence) would
  still pass both. This test group gives false green.
- `brand-design-system-handoff`: same non-discriminating shape as
  guide-and-spec — its Edit/MultiEdit replace_all cases assert
  outcome-only against a fixture where a single resolved occurrence
  already satisfies the (currently unpatched, defect-2-carrying) path-
  token check, so a broken `replace_all` would not flip the result.

Net: 2 of 4 plugins' replace_all tests are real mutation-sensitive
regression guards; 2 of 4 (guide-and-spec, system-handoff) are
non-discriminating padding — matches the issue's "3/4 허수" as counted
across the two group-1/group-2 case pairs in the two affected plugins
(one real distinguishing assertion needed per plugin, currently absent
in both).

## Defect 4 (confirmed): `hooks.json` matcher coverage vs. tested/advertised
Bash-write-target reachability

Each of the four `brand-design-*/hooks/hooks.json`:

```json
"matcher": "Write|Edit|MultiEdit"
```

No `Bash` matcher anywhere in any of the four. Each plugin's own test
suite (per issue-13's remediation) carries a group-6 case documenting
"a Bash-tool call whose target isn't Write/Edit/MultiEdit -> gate is out
of scope, exits 0" as **current, intended** behavior — so today the
tested branch and the wired matcher already agree (no Bash reachability
is claimed or tested as gated). This is consistent, not a defect by
itself.

The issue's requirement 2 ("hooks.json matcher와 코드의 도구 커버리지
완전 정합(광고·테스트된 분기가 프로덕션에서 도달 가능해야 함)") is a
forward invariant to hold, not a currently-broken match: verified there
is no case today where a gate's Python payload branches on `"Bash"` (or
any tool name) that the matcher doesn't route to the gate at all — see
`grep -n "gate_bash_write_targets\|\"Bash\""` across all four
`methodology-gate.sh`: zero hits. If core #75's newly-ported
`gate_lib.gate_bash_write_targets` py function is adopted into any of
these four gates' Bash handling (this proposal does not require that;
issue-13 explicitly kept Bash out of scope for policing), the matcher
must be extended to include `Bash` in the same change, or the new
branch is dead code the matcher never reaches. Recorded as a design
constraint, not an existing violation.

## Defect 5 (confirmed): root README documents `hooks/hooks.json` as
"SessionStart + PreToolUse wiring" — factually wrong for the file it
names

`README.md:23`:
```
- `brand-design/hooks/hooks.json` — SessionStart + PreToolUse wiring
```

Read `brand-design/hooks/hooks.json` directly: it carries **only** a
`SessionStart` hook (`directive.sh`). There is no `PreToolUse` entry in
this file. The four `PreToolUse` gates live in the four sibling
`brand-design-*/hooks/hooks.json` files (each already correctly
documented two lines below, per-plugin). This is the "README PreToolUse
서술 오류" the issue names — issue-13's README fix (defect 5 in that
issue) corrected the four-ghost-file listing but did not catch this
separate, adjacent misdescription of `brand-design/hooks/hooks.json`
itself.

## Ghost-file / old-role-name check (issue requirement 4)

Read all five `.claude-plugin/plugin.json` manifests and the root +
four sibling READMEs directly (full text, this survey): no references to
nonexistent files, and no old/pre-43-taxonomy role names anywhere
(`grep -rn "warrant-hunter\|record-fields-gate\|trailer-gate\|
handbook-trigger-gate"` across all `.md`/`.json` in this repo: zero
hits — issue-13's README fix already removed the last four ghost-file
lines and no new drift has appeared since). Requirement 4 is **already
satisfied** as of issue-13's phase-2 landing; this issue's residual is
defect 5 above (a real-file misdescription, not a ghost file), which
defect-5's fix also closes out under requirement 4's "0 잔재" bar.

## Summary table

| # | Defect | Scope | Status |
|---|---|---|---|
| 1 | Unguarded `gate-lib.sh` source (fail-open on missing core) | all 4 gates | confirmed, unfixed |
| 2 (N2) | Bare `\S+/\S+`-shaped path-token fallback | `system-handoff` only | confirmed, unfixed |
| 3 | Non-discriminating replace_all tests | `guide-and-spec`, `system-handoff` | confirmed, unfixed |
| 4 | matcher/code coverage invariant | all 4 | already consistent; hold as constraint |
| 5 | README `hooks.json` "PreToolUse" misdescription | root README | confirmed, unfixed |
| — | ghost files / old role names | manifests, READMEs | already clean (issue-13 landed it) |
