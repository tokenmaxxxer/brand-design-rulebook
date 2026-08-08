---
proposal: docs/issue-20/proposals/2026-08-09-brand-design-spec-vocabulary-alignment.md
---

# Hunt record — brand-design-spec-vocabulary-alignment

## after-proposal — stance 0: assume the gate just touched is bypassable — find the bypass.

Verdict: FINDING — phase-2 plan writes docs/specs/record-fields-terminal-states.json keyed by role name "brand-design", but core/hooks/record-fields-gate.sh requires override keys to be one of a fixed *kind* set (coding-record, qa-record, etc.) that brand-design is not mapped into anywhere, so the file the proposal plans to create denies every subsequent brand-design record write outright — the opposite of the "strengthening" the proposal claims.
Kind: design-error
Seed: docs/issue-20/proposals/2026-08-09-brand-design-spec-vocabulary-alignment.md step 4 (new file `docs/specs/record-fields-terminal-states.json` with content `{"brand-design": ["landed"]}`), verified against /home/jwjung/tokenmaxxxer-core/core/hooks/record-fields-gate.sh
cap_seconds: 60
tier: default
diff_stat_lines: 267
started_at: 2026-08-09T00:00:00Z
ended_at: 2026-08-09T00:20:00Z

### Reproduce
1. Create `docs/specs/record-fields-terminal-states.json` with exactly the content the proposal specifies for phase 2: `{"brand-design": ["landed"]}`.
2. Build a well-formed `Write` tool-use payload for the plugin's own record path (the pattern `docs/issue-<n>/reports/brand-design.md`, the exact target the `guide-and-spec` gate itself names) whose content has `loop_state: landed` — a fully terminal, otherwise-valid record.
3. Run `bash /home/jwjung/tokenmaxxxer-core/core/hooks/record-fields-gate.sh` with that payload on stdin, `CLAUDE_ROLE=brand-design`, `CLAUDE_PROJECT_DIR` set to a scratch root containing the override file above at `docs/specs/record-fields-terminal-states.json`.

### Observed
```
EXIT: 2
STDERR: brand-design: refused — docs/specs/record-fields-terminal-states.json names unrecognized kind 'brand-design' (not one of contract §2's record kinds: coding-record, feasibility-record, ops-record, product-record, qa-record, reflect-record, review-record, ux-design-record, verify-record); failing loudly instead of silently ignoring it (§20/C2).
```
Every brand-design record write is denied unconditionally once this override file exists, regardless of the record's own correctness — including the exact "landed" record the override is meant to recognize as terminal. `record-fields-gate.sh`'s `ROLE_TO_KIND` map (core/hooks/record-fields-gate.sh, ~line 158) has no `brand-design` entry either, so there is no path by which the role name `brand-design` is ever an accepted override key — this is not a transient bug but a structural mismatch between what the proposal plans to write and what the gate's override schema accepts (kind names, not role names).

### Expected
Per §20/C2 and the gate's own validation, the override key must be a *kind* (e.g. `coding-record`) drawn from `KIND_TERMINAL_DEFAULTS`, not a role name. A correct override for brand-design would first require brand-design to be added to `ROLE_TO_KIND` (or a `brand-design-record` kind added to `KIND_TERMINAL_DEFAULTS`) in core — neither of which this rulebook-side proposal can do, since `core/hooks/record-fields-gate.sh` lives outside this repo (in `tokenmaxxxer-core`, referenced but not vendored here). The proposal's phase-2 step 4 as written will fail-closed the role's entire record surface rather than strengthen it, and the proposal's "How you'll know it worked" section never actually runs `record-fields-gate.sh` against a real record, so this breakage would land invisibly.
