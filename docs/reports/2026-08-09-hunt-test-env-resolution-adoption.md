---
proposal: docs/issue-23/proposals/2026-08-09-test-env-resolution-adoption.md
---

# Hunt record — test-env-resolution-adoption

## after-proposal — stance 4: assume the write set cannot carry this work — find the path the build will need that the proposal does not list

Verdict: FINDING — the proposal's own example sibling-candidate path (`../../core`, relative to each `hooks/tests/` script) is one directory level too shallow to reach the same `core` location the gate-under-test's own fallback resolves to, so implementing "What will be done" literally as written yields a resolver that can never find core via step 2 even when the gate itself could.
Kind: design-error
Seed: docs/issue-23/proposals/2026-08-09-test-env-resolution-adoption.md ("What will be done" step 2: "Otherwise tries the script's existing repo-relative sibling candidate(s) (e.g. `../../core` ...)")
cap_seconds: 60
tier: default
diff_stat_lines: ~178 (docs-only: survey + proposal)
started_at: 2026-08-09T09:41:41+09:00
ended_at: 2026-08-09T09:48:00+09:00

### Reproduce
```
cd brand-design-rulebook-issue-23-implementation
grep -n 'gate-lib.sh' brand-design-guide-and-spec/hooks/methodology-gate.sh
# -> . "${CLAUDE_PLUGIN_ROOT_CORE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd -P)}/hooks/lib/gate-lib.sh"
# GATE lives at brand-design-guide-and-spec/hooks/methodology-gate.sh, so its
# fallback dirname(BASH_SOURCE)/../../core resolves relative to hooks/, i.e.
# two levels up from hooks/ = sibling of the plugin directory:
python3 -c "import os;print(os.path.normpath(os.path.join('brand-design-guide-and-spec/hooks','../../core')))"
# -> core   (sibling of the repo root / plugin directories)

# The tests script that the proposal edits lives one directory deeper, at
# brand-design-guide-and-spec/hooks/tests/methodology-gate-tests.sh (HERE).
# Applying the proposal's literal example candidate "../../core" from HERE:
python3 -c "import os;print(os.path.normpath(os.path.join('brand-design-guide-and-spec/hooks/tests','../../core')))"
# -> brand-design-guide-and-spec/core   (WRONG -- inside the plugin, does not exist, not what GATE uses)

python3 -c "import os;print(os.path.normpath(os.path.join('brand-design-guide-and-spec/hooks/tests','../../../core')))"
# -> core   (the depth actually needed to match GATE's own fallback)
```

### Observed
The proposal's step-2 example candidate `../../core`, taken literally and placed in `hooks/tests/methodology-gate-tests.sh` (one level deeper than `methodology-gate.sh`), resolves to `<plugin>/core` -- a location the gate itself never looks at and that does not exist -- instead of the sibling-of-repo `core` location `methodology-gate.sh`'s own fallback (`hooks/../../core`) resolves to. A resolver block coded from that example would silently fail to find a reachable core even in the exact spawn layout the gate itself supports, and would emit the new SKIP (exit 75) instead of exercising the "core IS reachable" assertions -- which is precisely the kind of silently-wrong outcome the constraint "no assertion that runs when core IS reachable may be weakened" is meant to prevent, achieved by a path-depth typo rather than an intentional trade-off.

### Expected
The candidate path in step 2, for scripts located at `<plugin>/hooks/tests/`, needs to be `../../../core` (three levels up) to match the depth `methodology-gate.sh`'s own `dirname(BASH_SOURCE)/../../core` fallback uses relative to `<plugin>/hooks/`. The proposal should state the correct depth (or better, state it per-script relative to each script's own location) rather than a single `../../core` example that is only correct for a script sitting directly in `hooks/`, not `hooks/tests/`.
