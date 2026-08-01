# issue-13 current-state survey (brand-design gate audit, grade B-)

## Scope
Four `brand-design-*` methodology-gate plugins (`guide-and-spec`,
`kapferer-scope-guard`, `system-handoff`, `wcag-consistency`), each with
its own `hooks/methodology-gate.sh` + `hooks/tests/methodology-gate-tests.sh`,
plus the repo root `README.md` and base `brand-design/` plugin.

## Confirmed defects (read from the live files, not the issue text alone)

1. **Path-token false positive hollows out asset-spec check.**
   `brand-design-guide-and-spec/hooks/methodology-gate.sh:184`:
   `path_or_format = ... or bool(re.search(r'\S+/\S+', new_text))`. Any
   occurrence of a slash-joined token pair — including the methodology's
   own vocabulary like `pass/fail`, `do's/don't`, `logo/typography` —
   satisfies this regex and marks `asset_spec_present = True` in
   combination with a single hex match, with no requirement that the
   matched token is a real file path. A record that only *talks about*
   pass/fail semantics, never a real asset path, passes.

2. **Kill-switch default is backwards (fail-open on typo).** All four
   `methodology-gate.sh` files use the pre-gate-house idiom at their
   kill-switch check (e.g. `guide-and-spec` line 26-29):
   `case "$FOO_OFF" in ""|0|false|no|off) ;; *) exit 0 ;; esac` — any
   unrecognized value, including a typo, disables the gate. This is
   exactly the bug `docs/handbooks/gate-house-standard.md` "the two bugs
   this issue fixed" §1 describes core's own canon having, now fixed
   upstream via `gate_kill_switch_active`. Not named in the issue body
   directly, but is the same defect class as the named fail-closed ask
   and belongs in the same remediation.

3. **Edit/MultiEdit ignore `replace_all`.** Same file, `Edit` branch
   (line 134-137): always `current.replace(o, n, 1)` regardless of
   `tool_input.get("replace_all")`. `MultiEdit` branch (line 138-151):
   same, per-edit, ignoring each edit's own `replace_all`. Matches
   `gate-house-standard.md`'s "two bugs" §2 exactly
   (`record-fields-gate.sh`'s pre-migration bug).

4. **Zero Edit/MultiEdit/malformed-JSON/kill-switch/absolute-path test
   coverage.** `brand-design-guide-and-spec/hooks/tests/
   methodology-gate-tests.sh` (28 lines) only ever synthesizes
   `tool_name: "Write"` payloads (5 cases: 2 deny, 3 allow). No case
   drives `Edit`, `MultiEdit`, malformed JSON, a kill-switch value, or an
   absolute/`./`-prefixed `file_path`. The other three plugins' test
   files were not independently re-verified line-by-line but share the
   same generator pattern (`run()` helper always emits `tool_name:
   "Write"`) per repo-wide grep — same gap, same fix needed across all
   four.

5. **README documents 4 nonexistent files.** Repo root `README.md`
   "Layout" section names `brand-design/hooks/record-fields-gate.sh`,
   `brand-design/hooks/trailer-gate.sh`,
   `brand-design/hooks/handbook-trigger-gate.sh`, and
   `brand-design/agents/warrant-hunter.md`. None exist — `brand-design/`
   on disk holds only `.claude-plugin/plugin.json`, `hooks/hooks.json`,
   `hooks/directive.sh`. These four gates/agents live in
   `core/hooks/*.sh` (referenced, not vendored) and this repo has no
   `agents/` directory at all. The four sibling `brand-design-*` plugin
   READMEs were checked too and are accurate against their own
   directories — the ghost-file defect is isolated to the root README.

## What core already provides (read from tokenmaxxxer-core, issue #72,
landed)

`core/hooks/lib/gate-lib.sh` + `gate-lib.py` (full text pulled via `gh api`)
supply, as sourceable/importable functions — see
`docs/handbooks/gate-house-standard.md` (also pulled) for the canonical
description:

- `gate_trap_fail_closed` (bash) — the one canonical fail-closed EXIT trap.
- `gate_kill_switch_active <value>` (bash) — fixed convention: only a
  recognized on-spelling disables; everything else (empty, off-spelling,
  unrecognized) stays active. Direct fix for defect 2.
- `gate_deny` / `gate_allow` (bash) — stderr-deny/exit-2, allow/exit-0.
- `gate_parse_json_or_deny(raw, deny)` (python) — malformed-JSON deny
  (empty, unparseable, non-object).
- `gate_normalize_path(root, path)` (python) — absolute/relative/`./`
  normalization to a root-relative tail, string-only (no filesystem
  touch — caller realpath's `root` itself if symlink-safety is needed).
- `gate_reconstruct_write(tool, tool_input, current_content)` (python) —
  full `Write`/`Edit`/`MultiEdit`/`NotebookEdit` reconstruction honoring
  per-edit `replace_all`. Direct fix for defect 3.
- `gate_bash_write_targets(command)` (bash) — path-token scan for
  Bash-tool writes.

`core/hooks/tests/run-gate-lib-tests.sh` fixes six mandatory case groups
(Edit+replace_all, MultiEdit mixed replace_all, malformed JSON,
unrecognized-kill-switch-stays-active, absolute+`./`-path, Bash-tool
write) — the exact shape issue-13 requirement 3 asks this repo to add.

`core/hooks/tests/compliance-check.sh [hooks-dir]` flags (a) a gate
reading a `*_OFF` var without `gate_kill_switch_active`, (b) a gate doing
its own `.replace(o, n[, 1])` instead of `gate_reconstruct_write`. Both
flags fire on all four `brand-design-*` gates as they stand today.

## Semantic-check gap (issue requirement 2)

Current checks (`guide_present`, `asset_spec_present` in
`guide-and-spec`; the analogous checks in the other three plugins, not
individually re-quoted here but same substring-membership shape) are all
`in low` substring membership over the entire flattened, lowercased
document text — no section boundary, no adjacency between a claim and
its evidence, no structural requirement that the "brand guide entry" and
the "asset spec" be distinguishable spans rather than the same sentence
satisfying both. This is what lets defect 1 happen at all: a substring
check has no notion of "this token is inside a path-shaped context" vs.
"this token is prose."
