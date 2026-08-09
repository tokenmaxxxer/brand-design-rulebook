---
status: proposed
files:
  - brand-design-guide-and-spec/hooks/tests/methodology-gate-tests.sh
  - brand-design-kapferer-scope-guard/hooks/tests/methodology-gate-tests.sh
  - brand-design-system-handoff/hooks/tests/methodology-gate-tests.sh
  - brand-design-wcag-consistency/hooks/tests/methodology-gate-tests.sh
---

## Request
Adopt the canonical test-env resolution convention landed at
`tokenmaxxxer/on-the-record`'s `docs/specs/test-env-resolution.md`
(issue #551): this rulebook's four `methodology-gate-tests.sh` scripts
assume the spawn env (`CLAUDE_PLUGIN_ROOT_CORE` set / core reachable at
a known sibling path) and fail with misleading `FAIL` lines on a plain
checkout instead of a clear SKIP verdict, without weakening any
assertion that still runs when core is reachable.

## Constraints
- Apply the convention's exact resolution order and SKIP contract
  (env var → caller-supplied sibling candidates → SKIP with the exact
  message and exit code `75`, distinct from the gate's own 0/1/2).
- Every script must reference the convention doc (acceptance criterion:
  `grep` hit for `test-env-resolution`).
- No assertion that runs when core IS reachable may be weakened,
  skipped, or have its expected outcome changed.
- No new dependency, runtime, or directory scaffolding for four
  bash-only call sites (this repo has no Python anywhere).
- A script whose failure turns out to be a real defect, not an
  environment gap, gets recorded as a finding, not masked with SKIP.

## Rationale
Considered vendoring the convention's reference Python module
(`gates/test_env_resolve.py`) and shelling out via `python3 -m
gates.test_env_resolve` per the doc's own "Bash test runner" adoption
recipe — this mirrors the upstream CLI shape most literally. Rejected:
this repo has zero Python infrastructure today, and introducing a new
`gates/` package plus a subprocess call for four ~10-line resolution
blocks is a heavier structural change than the problem needs; it would
also read as an operational-surface addition without a matching
handbook doc. Instead, each script gets a native bash implementation of
the same three-step order + SKIP contract, referencing the doc by name
so the convention stays a single source of truth even without shared
code.

Also considered a shared `hooks/tests/lib/resolve-core-env.sh` sourced
by all four scripts, to avoid repeating the block four times. Rejected
for this issue: no `hooks/tests/lib/` currently exists in this repo,
and each script already duplicates its own `report()`/`run()` test
helpers independently — adding shared infra now is a bigger, separate
structural change than what issue #23 asks for. Left as a possible
follow-up, not built here.

## What will be done
In each of the four scripts, replace the ad hoc/absent core-resolution
logic with a small resolver block, placed before any gate subprocess is
invoked, that:
1. Reads `CLAUDE_PLUGIN_ROOT_CORE` if set and it contains a non-empty
   `hooks/lib/gate-lib.sh`.
2. Otherwise tries the script's existing repo-relative sibling
   candidate(s) — critically, resolved from `hooks/tests/` (each test
   script's own directory), which is one level deeper than
   `methodology-gate.sh`'s `hooks/` directory: the gate's own fallback
   is `$(dirname methodology-gate.sh)/../../core` i.e. `hooks/../../core`,
   so the equivalent candidate from `hooks/tests/` is `../../../core`,
   not `../../core` (a `../../core` candidate would resolve one level
   too shallow and spuriously SKIP even when the gate itself could find
   core — caught by warrant-hunter dispatch,
   `docs/reports/2026-08-09-hunt-test-env-resolution-adoption.md`). For
   `wcag-consistency`, its existing hardcoded sibling path is retained
   as an additional candidate, not the only one, tried after `../../../core`.
3. Otherwise prints `SKIP: core plugin unreachable — unverifiable
   outside spawn env` to stderr and exits `75`, before running any
   `run()`/`run_payload()` case — so the whole file's verdict is an
   unambiguous SKIP, not a partial fail count.
Each block carries a comment naming `docs/specs/test-env-resolution.md`
(the convention doc's title/path) so `grep -r test-env-resolution`
finds every adopting script. `wcag-consistency`'s existing hardcoded
`CLAUDE_PLUGIN_ROOT_CORE=` export line is removed in favor of the
shared resolver block (env var still wins first, per the order).

## Out of scope
- Copying `docs/specs/test-env-resolution.md` itself into this repo —
  the convention lives at its landed home in `on-the-record`; this repo
  references it, per the acceptance check (grep for the string), not
  duplicates it.
- Vendoring the Python reference module or adding a `gates/` package.
- Building a shared `hooks/tests/lib/` helper (noted as a follow-up).
- Any change to the gates under test (`methodology-gate.sh` files) or
  to their pass/fail/deny semantics.
- CI wiring — no `.github/workflows` exists in this repo.

## How you'll know it worked
- `env -u CLAUDE_PLUGIN_ROOT_CORE bash <script>` on each of the four
  scripts exits `75` and prints the exact SKIP message to stderr, with
  zero `FAIL` lines (today: 9/9/7/6 FAIL respectively, per the survey).
- `bash <script>` run with `CLAUDE_PLUGIN_ROOT_CORE` pointed at a real
  core checkout still produces the same pass counts as before this
  change (20/17/19/18 passing, per the survey) — no regressed assertion.
- `grep -rl test-env-resolution brand-design-*/hooks/tests/` returns
  all four scripts.
