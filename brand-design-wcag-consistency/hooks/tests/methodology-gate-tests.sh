#!/usr/bin/env bash
# Real-subprocess gate tests for brand-design-wcag-consistency's
# methodology-gate.sh. Modeled on implementation-rulebook/tests/
# run-gate-tests.sh's shape, extended (issue-13) with the gate-house
# standard's mandatory test-case groups (replace_all, MultiEdit mixed
# replace_all, malformed JSON, kill-switch, path-equivalence, out-of-scope
# tool, paragraph-scoping).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
GATE="$HERE/../methodology-gate.sh"

# --- test-env resolution (docs/specs/test-env-resolution.md, on-the-record
# issue #551): resolve core outside the spawn env or SKIP, rather than
# letting the gate's own guarded gate-lib.sh source fail closed and report
# misleading FAILs. Order: $CLAUDE_PLUGIN_ROOT_CORE (non-empty gate-lib.sh)
# -> sibling candidate (non-empty gate-lib.sh, ../../../core first, this
# script's prior hardcoded sibling retained as a further candidate) ->
# SKIP, exit 75. ---
_resolve_core() {
  if [ -n "${CLAUDE_PLUGIN_ROOT_CORE:-}" ] && [ -s "$CLAUDE_PLUGIN_ROOT_CORE/hooks/lib/gate-lib.sh" ]; then
    return 0
  fi
  local candidate resolved
  for candidate in "$HERE/../../../core" "$HERE/../../../../tokenmaxxxer-core-issue-72-implementation/core"; do
    resolved="$(cd "$candidate" 2>/dev/null && pwd -P)"
    if [ -n "$resolved" ] && [ -s "$resolved/hooks/lib/gate-lib.sh" ]; then
      export CLAUDE_PLUGIN_ROOT_CORE="$resolved"
      return 0
    fi
  done
  return 1
}
if ! _resolve_core; then
  echo "SKIP: core plugin unreachable — unverifiable outside spawn env" >&2
  exit 75
fi

pass=0; fail=0
report() { if [ "$2" = "$1" ]; then pass=$((pass+1)); printf 'ok     %-34s %s\n' "$3" "$2"; else fail=$((fail+1)); printf 'FAIL   %-34s want=%s got=%s\n' "$3" "$1" "$2"; fi; }

REC=docs/issue-10/reports/brand-design.md

# run want name file content
# Simple Write-tool case (no pre-existing file on disk), as before.
run() {
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/docs/issue-10/reports"
  printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":%s},"cwd":"%s"}' \
    "$3" "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$4")" "$td" \
    | env CLAUDE_PROJECT_DIR="$td" /bin/bash "$GATE" >/dev/null 2>&1
  rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$1" "$got" "$2"
}

# run_payload want name payload_json [existing_content] [env_assignments...]
# Generic runner: builds a project dir, optionally seeds the record file
# with existing_content, feeds payload_json (a python-format string with
# {path} and {cwd} placeholders) on stdin, and runs the gate with any
# extra ENV=VAL assignments.
run_payload() {
  local want="$1" name="$2" payload="$3" existing="${4-}"; shift 4 || true
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/docs/issue-10/reports"
  if [ -n "$existing" ]; then
    printf '%s' "$existing" > "$td/$REC"
  fi
  payload="${payload//\{cwd\}/$td}"
  printf '%s' "$payload" | env CLAUDE_PROJECT_DIR="$td" "$@" /bin/bash "$GATE" >/dev/null 2>&1
  rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$want" "$got" "$name"
}

jstr() { python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$1"; }

# --- static: hooks.json PreToolUse matcher covers every tool-name literal
# methodology-gate.sh branches on (no uncovered literal today) -------------
HOOKS_JSON="$HERE/../hooks.json"
matcher="$(python3 -c '
import json,sys
try:
    with open(sys.argv[1]) as f:
        d = json.load(f)
    print(d["hooks"]["PreToolUse"][0]["matcher"])
except Exception:
    print("")
' "$HOOKS_JSON")"
IFS='|' read -r -a matcher_alts <<< "$matcher"
uncovered=""
# Only scan lines where the gate branches on the parsed tool-name variable
# (e.g. `tool not in (...)`, `tool ==`), not arbitrary quoted strings
# elsewhere in the file (label words, paths, etc.).
tool_name_lits="$(grep -E '\btool (not )?in \(|\btool ==' "$GATE" | grep -oE '"[A-Za-z][A-Za-z0-9]*"' | tr -d '"' | sort -u)"
for lit in $tool_name_lits; do
  found=0
  for alt in "${matcher_alts[@]}"; do
    [ "$alt" = "$lit" ] && found=1 && break
  done
  if [ "$found" -eq 0 ]; then
    uncovered="$uncovered $lit"
  fi
done
if [ -n "$uncovered" ]; then
  fail=$((fail+1))
  printf 'FAIL   %-34s hooks.json matcher=%s missing coverage for:%s\n' "matcher-vs-gate-tool-coverage" "$matcher" "$uncovered"
else
  pass=$((pass+1))
  printf 'ok     %-34s matcher=%s covers all gate tool-name literals\n' "matcher-vs-gate-tool-coverage" "$matcher"
fi

run deny  wcag-number-unlabeled "$REC" 'consistency check: new text/background pairing introduced, contrast ratio measured at 4.6'
run allow no-new-pairing-early-exit "$REC" 'consistency check: no new text/background pairing introduced this change.'
run allow wcag-complete "$REC" $'consistency check: new pairing\ncontrast ratio 4.6:1, pass against AA 4.5:1.'
run allow foreign-path "docs/issue-10/reports/qa.md" "x"

# --- (a) Edit with replace_all: true, old_string occurs multiple times ---
existing_a=$'consistency check: placeholder\ncontrast ratio TBD, TBD\n\nconsistency check: placeholder\ncontrast ratio TBD, TBD\n'
payload_a=$(python3 -c '
import json
ti = {
    "file_path": "docs/issue-10/reports/brand-design.md",
    "old_string": "TBD, TBD",
    "new_string": "4.6:1, pass against AA 4.5:1",
    "replace_all": True,
}
print(json.dumps({"tool_name": "Edit", "tool_input": ti, "cwd": "{cwd}"}))
')
run_payload allow edit-replace-all-multi-occurrence "$payload_a" "$existing_a"

# --- (b) MultiEdit with mixed replace_all true/false in same call ---
existing_b=$'consistency check: placeholder\ncontrast ratio X, X\n\nconsistency check: placeholder\ncontrast ratio X, X\n'
payload_b=$(python3 -c '
import json
edits = [
    {"old_string": "placeholder", "new_string": "new pairing", "replace_all": True},
    {"old_string": "X, X", "new_string": "4.6:1, pass against AA 4.5:1", "replace_all": False},
]
ti = {"file_path": "docs/issue-10/reports/brand-design.md", "edits": edits}
print(json.dumps({"tool_name": "MultiEdit", "tool_input": ti, "cwd": "{cwd}"}))
')
# After edits: both "placeholder" occurrences become "new pairing" (replace_all),
# but only the first "X, X" becomes the ratio/verdict text (replace_all false) —
# the second paragraph is left with "X, X" (no ratio/verdict) -> still missing
# -> deny expected, proving per-edit replace_all was honored (not global).
run_payload deny multiedit-mixed-replace-all "$payload_b" "$existing_b"

# --- (c) Malformed JSON on stdin ---
td_c="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td_c"; mkdir -p "$td_c/docs/issue-10/reports"
printf '{"tool_name":"Write","tool_input":{"file_path"' | env CLAUDE_PROJECT_DIR="$td_c" /bin/bash "$GATE" >/dev/null 2>&1
rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
report deny "$got" json-truncated
rm -rf "$td_c"

td_c2="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td_c2"; mkdir -p "$td_c2/docs/issue-10/reports"
printf '[1,2,3]' | env CLAUDE_PROJECT_DIR="$td_c2" /bin/bash "$GATE" >/dev/null 2>&1
rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
report deny "$got" json-not-object-array
rm -rf "$td_c2"

td_c3="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td_c3"; mkdir -p "$td_c3/docs/issue-10/reports"
printf '"just a string"' | env CLAUDE_PROJECT_DIR="$td_c3" /bin/bash "$GATE" >/dev/null 2>&1
rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
report deny "$got" json-not-object-string
rm -rf "$td_c3"

td_c4="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td_c4"; mkdir -p "$td_c4/docs/issue-10/reports"
printf '' | env CLAUDE_PROJECT_DIR="$td_c4" /bin/bash "$GATE" >/dev/null 2>&1
rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
report deny "$got" json-empty-stdin
rm -rf "$td_c4"

# --- (d) Kill-switch set to unrecognized value stays ACTIVE ---
run_payload deny kill-switch-unrecognized-value-stays-active \
  "$(python3 -c 'import json; print(json.dumps({"tool_name":"Write","tool_input":{"file_path":"docs/issue-10/reports/brand-design.md","content":"consistency check: new text/background pairing introduced, contrast ratio measured at 4.6"},"cwd":"{cwd}"}))')" \
  "" env BRAND_DESIGN_WCAG_CONSISTENCY_GATE_OFF=banana

# --- (e) Absolute file_path and ./-prefixed relative variant resolve identically ---
payload_e_content='consistency check: new text/background pairing introduced, contrast ratio measured at 4.6'
td_e="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td_e"; mkdir -p "$td_e/docs/issue-10/reports"
printf '{"tool_name":"Write","tool_input":{"file_path":"%s/%s","content":%s},"cwd":"%s"}' \
  "$td_e" "$REC" "$(jstr "$payload_e_content")" "$td_e" \
  | env CLAUDE_PROJECT_DIR="$td_e" /bin/bash "$GATE" >/dev/null 2>&1
rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
report deny "$got" absolute-path-same-outcome
rm -rf "$td_e"

td_e2="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td_e2"; mkdir -p "$td_e2/docs/issue-10/reports"
printf '{"tool_name":"Write","tool_input":{"file_path":"./%s","content":%s},"cwd":"%s"}' \
  "$REC" "$(jstr "$payload_e_content")" "$td_e2" \
  | env CLAUDE_PROJECT_DIR="$td_e2" /bin/bash "$GATE" >/dev/null 2>&1
rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
report deny "$got" dot-relative-path-same-outcome
rm -rf "$td_e2"

# --- (f) Non-Write/Edit/MultiEdit tool (Bash) -> exit 0 pass-through ---
run_payload allow bash-tool-out-of-scope \
  "$(python3 -c 'import json; print(json.dumps({"tool_name":"Bash","tool_input":{"command":"echo hi"},"cwd":"{cwd}"}))')" \
  ""

# --- (g) paragraph-scoping: ratio in one section, verdict in an unrelated
# section -> must DENY (not incorrectly pass) ---
scoping_bad='## Unrelated background note

pass

## consistency check

new text/background pairing introduced, ratio pending: 4.6:1'
run deny scoping-cross-section-must-deny "$REC" "$scoping_bad"

# --- (h) paragraph-scoping: ratio+verdict correctly co-located -> ALLOW ---
scoping_good='## consistency check

new text/background pairing introduced, contrast ratio 4.6:1, pass against AA 4.5:1.'
run allow scoping-co-located-allows "$REC" "$scoping_good"

# --- group 7: missing-core -> guarded source must deny, not silently allow
td_g="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td_g"; mkdir -p "$td_g/docs/issue-10/reports"
printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":%s}}' \
  "$REC" "$(jstr 'consistency check: no new text/background pairing introduced this change.')" \
  | env CLAUDE_ROLE=brand-design CLAUDE_PROJECT_DIR="$td_g" \
    CLAUDE_PLUGIN_ROOT_CORE="$td_g/no-such-core" \
    /bin/bash "$GATE" >/dev/null 2>&1
rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
report deny "$got" missing-core-guarded-source-denies
rm -rf "$td_g"

printf '\n== %d passed, %d failed ==\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
