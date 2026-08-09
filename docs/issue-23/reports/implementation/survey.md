# Survey — issue #23 (adopt test-env resolution convention)

## Upstream convention (on-the-record issue #551, closed COMPLETED)
Fetched from `tokenmaxxxer/on-the-record` branch `issue-551/implementation`,
path `docs/specs/test-env-resolution.md` (that issue is closed as landed —
approval comment `APPROVE issue-551/implementation` present):

- Resolution order: (1) `$CLAUDE_PLUGIN_ROOT_CORE` if set and it contains
  `hooks/lib/gate-lib.sh`; (2) first caller-supplied sibling-checkout
  candidate containing `hooks/lib/gate-lib.sh` (no path hardcoded inside
  the convention itself — candidates are supplied by the *caller*);
  (3) otherwise **SKIP**: print `SKIP: core plugin unreachable —
  unverifiable outside spawn env` to stderr, exit `75` (`EX_TEMPFAIL`,
  distinct from a gate's own 0/1/2).
- A zero-byte/stub `gate-lib.sh` must NOT count as resolved (empty-stub
  guard, added after that repo's own warrant hunt).
- Adoption shape for a **bash test runner** (this repo's shape — no
  Python/pytest anywhere in this rulebook): invoke the reference module
  as a CLI, or (since no Python dependency exists here today and adding
  one is out of scope for a doc-adoption issue) implement the same
  three-step order + SKIP contract natively in bash, referencing the
  convention doc.
- "Out of scope" in the convention doc itself: applying it inside each
  of the 23 consumer repos is separate, per-repo work — this issue.

## This repo's write surface
Four `hooks/tests/methodology-gate-tests.sh` scripts assume the spawn
env (each sources `../methodology-gate.sh`, which sources
`${CLAUDE_PLUGIN_ROOT_CORE:-<repo-relative fallback>}/hooks/lib/gate-lib.sh`):

- `brand-design-guide-and-spec/hooks/tests/methodology-gate-tests.sh`
- `brand-design-kapferer-scope-guard/hooks/tests/methodology-gate-tests.sh`
- `brand-design-system-handoff/hooks/tests/methodology-gate-tests.sh`
- `brand-design-wcag-consistency/hooks/tests/methodology-gate-tests.sh`

Confirmed by running each with `env -u CLAUDE_PLUGIN_ROOT_CORE bash
<script>` (this session's shell has `CLAUDE_PLUGIN_ROOT_CORE` set from
the spawn env, so it had to be explicitly unset to reproduce a plain
checkout):

| script | pass/total in spawn env | pass/total outside (env -u) |
|---|---|---|
| guide-and-spec | 20/20 | 11/20 (9 FAIL) |
| kapferer-scope-guard | 17/17 | 8/17 (9 FAIL) |
| system-handoff | 19/19 | 12/19 (7 FAIL) |
| wcag-consistency | 18/18 | 12/18 (6 FAIL) |

All failures outside spawn env are the *same shape*: cases expecting
`allow` get `got=deny`, because the gate's guarded `gate-lib.sh` source
fails closed (exit 2) when core is unreachable — not a defect in the
gates themselves. No script currently distinguishes "core unreachable,
unverifiable" from "gate actually denied a would-be-allowed input";
every one of these runs reports a misleading `N failed` instead of a
clear SKIP verdict.

`wcag-consistency`'s script already half-attempts env resolution
(`hooks/tests/methodology-gate-tests.sh:11`) via one hardcoded sibling
path (`../../../../tokenmaxxxer-core-issue-72-implementation/core`) —
this is exactly the ad hoc per-repo pattern issue #551 exists to
replace; it does not SKIP, it silently falls through to the same
misleading-failure behavior when that specific path doesn't exist.

No other test scripts in this repo exist (`find . -iname
"*.sh" -path "*/tests/*"` returns exactly these four); no CI workflow
file references them (`.github/workflows` absent from this repo).

## Alternatives considered while surveying
- **Vendor the reference Python module (`gates/test_env_resolve.py`)
  and shell out via `python3 -m gates.test_env_resolve`**: mirrors the
  convention doc's own CLI adoption shape most literally, but this repo
  has no Python anywhere and no dependency infra for it — would need a
  new `gates/` directory, an operational-surface-adjacent addition, for
  four call sites in scripts that are already plain bash. Rejected in
  favor of a native bash implementation of the same three-step
  order + SKIP contract (still grep-referencing the convention doc, per
  acceptance criterion 3), which needs no new file type or runtime.
- **Add a shared bash helper script (e.g.
  `hooks/tests/lib/resolve-core-env.sh`) sourced by all four**: was
  the frontrunner for a bit since it avoids repeating the same ~10-line
  block four times, but doctrine's write-set framing plus the fact that
  each test script already independently duplicates its own
  `report()`/`run()` helpers (no shared `hooks/tests/lib/` exists in this
  repo today) means introducing shared infra is a bigger structural
  change than four inline blocks. Rejected for this issue; flagged as a
  possible follow-up, not adopted here.
