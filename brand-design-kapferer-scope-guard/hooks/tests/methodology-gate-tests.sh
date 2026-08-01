#!/usr/bin/env bash
# Real-subprocess gate tests for brand-design-kapferer-scope-guard's
# methodology-gate.sh. Modeled on implementation-rulebook/tests/
# run-gate-tests.sh's shape, plus the six mandatory test-case groups from
# core/hooks/tests/run-gate-lib-tests.sh (issue-13 remediation): replace_all
# Edit, mixed-replace_all MultiEdit, malformed JSON, kill-switch-unrecognized-
# value, absolute/./-prefixed path equivalence, out-of-scope tool.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
GATE="$HERE/../methodology-gate.sh"
pass=0; fail=0
report() { if [ "$2" = "$1" ]; then pass=$((pass+1)); printf 'ok     %-34s %s\n' "$3" "$2"; else fail=$((fail+1)); printf 'FAIL   %-34s want=%s got=%s\n' "$3" "$1" "$2"; fi; }

PROPOSAL=docs/issue-10/proposals/2026-07-31-brand-design-x.md
REC=docs/issue-10/reports/brand-design.md

run() { # want name file content
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"
  mkdir -p "$td/docs/issue-10/proposals" "$td/docs/issue-10/reports"
  printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":%s},"cwd":"%s"}' \
    "$3" "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$4")" "$td" \
    | env CLAUDE_PROJECT_DIR="$td" BRAND_DESIGN_KAPFERER_SCOPE_GUARD_GATE_OFF="${GATEOFF:-}" CLAUDE_PLUGIN_ROOT_CORE="${CLAUDE_PLUGIN_ROOT_CORE:-}" /bin/bash "$GATE" >/dev/null 2>&1
  rc="${PIPESTATUS[1]}"; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$1" "$got" "$2"
}

# run_payload: send an arbitrary raw stdin payload (used for malformed-JSON /
# non-standard-tool / edit / multiedit / path-variant cases).
run_payload() { # want name payload td_setup_fn
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"
  mkdir -p "$td/docs/issue-10/proposals" "$td/docs/issue-10/reports"
  if [ -n "${4:-}" ]; then "$4" "$td"; fi
  printf '%s' "$3" \
    | env CLAUDE_PROJECT_DIR="$td" BRAND_DESIGN_KAPFERER_SCOPE_GUARD_GATE_OFF="${GATEOFF:-}" CLAUDE_PLUGIN_ROOT_CORE="${CLAUDE_PLUGIN_ROOT_CORE:-}" /bin/bash "$GATE" >/dev/null 2>&1
  rc="${PIPESTATUS[1]}"; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$1" "$got" "$2"
}

jstr() { python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$1"; }

# ---- static assertion: hooks.json PreToolUse matcher and this gate's own
# tool-name coverage must agree (regression guard for future drift) ----
HOOKS_JSON="$HERE/../hooks.json"
matcher="$(grep -o '"matcher"[[:space:]]*:[[:space:]]*"[^"]*"' "$HOOKS_JSON" | head -n1 | sed -E 's/.*:[[:space:]]*"([^"]*)"/\1/')"
IFS='|' read -r -a matcher_tools <<< "$matcher"
uncovered=""
for lit in $(grep -oE '"[A-Za-z][A-Za-z0-9]*"' "$GATE" | tr -d '"' | sort -u); do
  case "$lit" in
    Write|Edit|MultiEdit) continue ;;
  esac
  found=0
  for mt in "${matcher_tools[@]}"; do
    [ "$mt" = "$lit" ] && { found=1; break; }
  done
  # only flag literals that also appear as a tool-name-shaped branch literal
  # (i.e. ones that are among the gate's own known Write/Edit/MultiEdit set
  # semantics) — approximate by checking it's compared against tool_name
  if [ "$found" -eq 0 ] && grep -qE "tool ==? \"$lit\"|tool_name.*\"$lit\"|\"$lit\".*tool" "$GATE"; then
    uncovered="$uncovered $lit"
  fi
done
if [ -n "$uncovered" ]; then
  fail=$((fail+1))
  printf 'FAIL   %-34s hooks.json matcher missing:%s\n' "matcher-coverage-static-check" "$uncovered"
else
  pass=$((pass+1))
  printf 'ok     %-34s %s\n' "matcher-coverage-static-check" "consistent"
fi

# ---- existing cases (fixture content updated for label/heading-shaped,
# adjacency-scoped semantics) ----
run deny  scope-boundary-missing "$PROPOSAL" 'This proposal covers everything about the brand.'
run allow scope-boundary-present "$PROPOSAL" $'Scope:\nThis proposal covers only the Physique facet (Kapferer), per YOU_DECIDE.'
run deny  prohibitions-not-acknowledged "$REC" $'Prohibitions:\nWork done: new color introduced.'
run allow prohibitions-acknowledged "$REC" $'Prohibitions:\nundocumented color not triggered; WCAG number omitted not triggered.'
run allow foreign-path "docs/issue-10/reports/qa.md" "x"
GATEOFF=1 run allow kill-switch-off "$REC" 'nothing at all'

# ---- (a) Edit with replace_all: true against a multiply-occurring
# old_string — assert full replacement reflected. Old content has the scope
# label missing the acknowledgement text twice; replace_all swaps both
# occurrences of a placeholder into the Kapferer scope phrase, so a
# first-occurrence-only reconstruction would still deny while the correct
# replace_all reconstruction allows. ----
setup_edit_replace_all() {
  td="$1"
  printf 'Scope:\nPLACEHOLDER and PLACEHOLDER again.\n' > "$td/$PROPOSAL"
}
payload_edit_replace_all="$(python3 -c '
import json
ti = {"file_path": "'"$PROPOSAL"'", "old_string": "PLACEHOLDER", "new_string": "Physique facet (Kapferer)", "replace_all": True}
print(json.dumps({"tool_name": "Edit", "tool_input": ti}))
')"
run_payload allow edit-replace-all-true "$payload_edit_replace_all" setup_edit_replace_all

# ---- (b) MultiEdit with mixed replace_all true/false edits in one call ----
setup_multiedit_mixed() {
  td="$1"
  printf 'Prohibitions:\nFOO FOO status BAR.\n' > "$td/$REC"
}
payload_multiedit_mixed="$(python3 -c '
import json
edits = [
    {"old_string": "FOO", "new_string": "undocumented color not triggered", "replace_all": True},
    {"old_string": "BAR", "new_string": "WCAG number omitted not triggered", "replace_all": False},
]
ti = {"file_path": "'"$REC"'", "edits": edits}
print(json.dumps({"tool_name": "MultiEdit", "tool_input": ti}))
')"
run_payload allow multiedit-mixed-replace-all "$payload_multiedit_mixed" setup_multiedit_mixed

# ---- (c) Malformed JSON on stdin — assert deny ----
run_payload deny malformed-json-truncated '{"tool_name":"Write","tool_input":{'
run_payload deny malformed-json-non-object '"just a string"'
run_payload deny malformed-json-empty ''

# ---- (d) Kill-switch env var set to an unrecognized value — gate stays
# ACTIVE (fail-open-on-unrecognized-value regression guard) ----
GATEOFF=banana run deny kill-switch-unrecognized-stays-active "$PROPOSAL" 'This proposal covers everything about the brand.'

# ---- (e) Absolute file_path and a ./-prefixed variant reaching the same
# record as a relative-path fixture — assert identical outcome (allow) ----
run_payload_abs() { # want name relpath content
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"
  mkdir -p "$td/docs/issue-10/proposals" "$td/docs/issue-10/reports"
  printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":%s},"cwd":"%s"}' \
    "$td/$3" "$(jstr "$4")" "$td" \
    | env CLAUDE_PROJECT_DIR="$td" BRAND_DESIGN_KAPFERER_SCOPE_GUARD_GATE_OFF="${GATEOFF:-}" CLAUDE_PLUGIN_ROOT_CORE="${CLAUDE_PLUGIN_ROOT_CORE:-}" /bin/bash "$GATE" >/dev/null 2>&1
  rc="${PIPESTATUS[1]}"; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$1" "$got" "$2"
}
run_payload_dotslash() { # want name relpath content
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"
  mkdir -p "$td/docs/issue-10/proposals" "$td/docs/issue-10/reports"
  printf '{"tool_name":"Write","tool_input":{"file_path":"./%s","content":%s},"cwd":"%s"}' \
    "$3" "$(jstr "$4")" "$td" \
    | env CLAUDE_PROJECT_DIR="$td" BRAND_DESIGN_KAPFERER_SCOPE_GUARD_GATE_OFF="${GATEOFF:-}" CLAUDE_PLUGIN_ROOT_CORE="${CLAUDE_PLUGIN_ROOT_CORE:-}" /bin/bash "$GATE" >/dev/null 2>&1
  rc="${PIPESTATUS[1]}"; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$1" "$got" "$2"
}
run_payload_abs      allow abs-path-scope-boundary-present "$PROPOSAL" $'Scope:\nThis proposal covers only the Physique facet (Kapferer), per YOU_DECIDE.'
run_payload_dotslash allow dotslash-path-scope-boundary-present "$PROPOSAL" $'Scope:\nThis proposal covers only the Physique facet (Kapferer), per YOU_DECIDE.'

# ---- (f) A non-Write/Edit/MultiEdit tool (Bash) — out of scope, exit 0 ----
payload_bash_tool='{"tool_name":"Bash","tool_input":{"command":"echo hi"}}'
run_payload allow non-write-tool-out-of-scope "$payload_bash_tool" ""

# ---- group 7: missing-core — CLAUDE_PLUGIN_ROOT_CORE points at a
# nonexistent path; gate-lib.sh cannot be sourced, so the gate must fail
# closed (deny) rather than silently allow (modeled on core's own
# run-gate-lib-tests.sh missing-core pattern) ----
td_missing_core="$(cd "$(mktemp -d)" && pwd -P)"
CLAUDE_PLUGIN_ROOT_CORE="$td_missing_core/no-such-core" run_payload deny missing-core-fails-closed "$payload_bash_tool" ""
rm -rf "$td_missing_core"

printf '\n== %d passed, %d failed ==\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
