#!/usr/bin/env bash
# Real-subprocess gate tests for brand-design-system-handoff's
# methodology-gate.sh. Modeled on implementation-rulebook/tests/
# run-gate-tests.sh's shape; six mandatory test-case groups mirror
# core/hooks/tests/run-gate-lib-tests.sh's shape (issue-13 remediation):
#   1. Edit with replace_all: true against a multiply-occurring old_string.
#   2. MultiEdit with mixed replace_all true/false edits in one call.
#   3. Malformed JSON on stdin (truncated, non-object, empty).
#   4. Kill-switch env var set to an unrecognized value -> stays ACTIVE.
#   5. Absolute file_path and a ./-prefixed variant reach the same record
#      a relative-path fixture reaches.
#   6. A non-Write/Edit/MultiEdit tool (Bash) -> exit 0 (out of scope).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
GATE="$HERE/../methodology-gate.sh"

# --- test-env resolution (docs/specs/test-env-resolution.md, on-the-record
# issue #551): resolve core outside the spawn env or SKIP, rather than
# letting the gate's own guarded gate-lib.sh source fail closed and report
# misleading FAILs. Order: $CLAUDE_PLUGIN_ROOT_CORE (non-empty gate-lib.sh)
# -> sibling candidate (non-empty gate-lib.sh) -> SKIP, exit 75. ---
_resolve_core() {
  if [ -n "${CLAUDE_PLUGIN_ROOT_CORE:-}" ] && [ -s "$CLAUDE_PLUGIN_ROOT_CORE/hooks/lib/gate-lib.sh" ]; then
    return 0
  fi
  local candidate resolved
  for candidate in "$HERE/../../../core"; do
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
report() { if [ "$2" = "$1" ]; then pass=$((pass+1)); printf 'ok     %-50s %s\n' "$3" "$2"; else fail=$((fail+1)); printf 'FAIL   %-50s want=%s got=%s\n' "$3" "$1" "$2"; fi; }

groups_seen=""
mark() { groups_seen="$groups_seen $1"; }

# --- static assertion: hooks.json PreToolUse matcher covers every
# tool-name literal methodology-gate.sh branches on. Run once at suite
# start, fail loudly (not silently) if a literal is uncovered. ------------
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
for lit in $(grep -oE '"[A-Za-z][A-Za-z0-9]*"' "$GATE" | tr -d '"' | sort -u); do
  case "$lit" in
    Write|Edit|MultiEdit) continue ;;
  esac
  found=0
  for alt in "${matcher_alts[@]}"; do
    [ "$alt" = "$lit" ] && found=1 && break
  done
  if [ "$found" -eq 0 ] && grep -qE 'tool ==? "'"$lit"'"|tool_name.*"'"$lit"'"|"'"$lit"'".*tool' "$GATE"; then
    uncovered="$uncovered $lit"
  fi
done
if [ -n "$uncovered" ]; then
  fail=$((fail+1))
  printf 'FAIL   %-50s hooks.json matcher=%s missing coverage for:%s\n' "matcher-vs-gate-tool-coverage" "$matcher" "$uncovered"
else
  pass=$((pass+1))
  printf 'ok     %-50s matcher=%s covers all gate tool-name literals\n' "matcher-vs-gate-tool-coverage" "$matcher"
fi

REC=docs/issue-10/reports/brand-design.md

run() { # want name file content
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/docs/issue-10/reports"
  printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":%s},"cwd":"%s"}' \
    "$3" "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$4")" "$td" \
    | env CLAUDE_PROJECT_DIR="$td" /bin/bash "$GATE" >/dev/null 2>&1
  rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$1" "$got" "$2"
}

# run_raw lets a caller build the full JSON payload/tool_input directly,
# for cases run()'s Write-only shape cannot express (Edit/MultiEdit/
# malformed JSON/absolute paths/non-Write tools).
run_raw() { # want name payload [project_dir_override] [existing-file-rel] [existing-file-content]
  want="$1"; name="$2"; payload="$3"; pd="${4:-}"; exrel="${5:-}"; excontent="${6:-}"
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/docs/issue-10/reports"
  if [ -n "$exrel" ]; then
    mkdir -p "$td/$(dirname "$exrel")"
    printf '%s' "$excontent" > "$td/$exrel"
  fi
  proj="$td"; [ -n "$pd" ] && proj="$pd"
  printf '%s' "$payload" | env CLAUDE_PROJECT_DIR="$proj" /bin/bash "$GATE" >/dev/null 2>&1
  rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$want" "$got" "$name"
}

# --- existing cases (fixture content updated to label/paragraph shape) ----
run deny  design-system-paths-missing "$REC" 'design-system should implement tokens for color and spacing eventually.'
run allow design-system-paths-present "$REC" 'design-system source paths: src/tokens/color.json, src/tokens/spacing.json'
run allow foreign-path "docs/issue-10/reports/qa.md" "x"
run allow not-applicable-allowance "$REC" 'design-system source paths: not applicable — no new pairing introduced this phase.'

CONTENT_GOOD='design-system source paths: src/tokens/color.json

## other section
some/other/path.json'

# --- group 1: Edit replace_all discrimination ------------------------------
# Design-3 fix (defect 3): the old fixture put the label's only path token
# entirely inside the FIRST occurrence of old_string, so a broken
# first-occurrence-only reconstruction (replace_all:false) already produced
# a passing paragraph — the outcome-only assertion couldn't tell a correct
# replace_all from a broken one. Fixed by placing PLACEHOLDER once BEFORE
# the design-system-source-paths paragraph and once INSIDE it: with
# replace_all:true both resolve to a valid extensioned path (allow); with
# replace_all:false only the first (pre-paragraph) occurrence resolves and
# the in-paragraph occurrence is left as literal, non-path text (deny) —
# genuinely discriminating on the replace_all flag, modeled on
# brand-design-kapferer-scope-guard's and brand-design-wcag-consistency's
# multi-occurrence-in-one-call technique.
mark replace_all-edit
REPLACE_ALL_FIXTURE='PLACEHOLDER

design-system source paths: PLACEHOLDER'
run_raw allow "Edit replace_all:true resolves every occurrence (label paragraph gets a real path)" \
  "$(python3 -c '
import json
tool_input = {"file_path":"'"$REC"'","old_string":"PLACEHOLDER","new_string":"src/tokens/color.json","replace_all":True}
payload = {"tool_name":"Edit","tool_input":tool_input}
print(json.dumps(payload))
')" "" "$REC" "$REPLACE_ALL_FIXTURE"
run_raw deny "Edit replace_all:false only resolves the first occurrence (label paragraph still unresolved)" \
  "$(python3 -c '
import json
tool_input = {"file_path":"'"$REC"'","old_string":"PLACEHOLDER","new_string":"src/tokens/color.json","replace_all":False}
payload = {"tool_name":"Edit","tool_input":tool_input}
print(json.dumps(payload))
')" "" "$REC" "$REPLACE_ALL_FIXTURE"

# --- group 2: MultiEdit with mixed replace_all true/false in one call -----
# Same Design-3 discrimination technique, per-edit: one edit (on an
# unrelated token, AAA) uses replace_all:true; the other edit is the one
# that actually matters for the check (PLACEHOLDER, appearing once before
# and once inside the design-system-source-paths paragraph). The allow case
# gives that edit replace_all:true (both PLACEHOLDER occurrences resolve);
# the deny case gives it replace_all:false (in-paragraph occurrence stays
# unresolved) — proving per-edit replace_all is honored independently, not
# globally, and that the outcome actually tracks the flag.
mark multiedit-replace_all
run_raw allow "MultiEdit per-edit replace_all:true on the load-bearing edit yields passing record" \
  "$(python3 -c '
import json
edits = [
  {"old_string":"AAA","new_string":"ok","replace_all":True},
  {"old_string":"PLACEHOLDER","new_string":"src/tokens/color.json","replace_all":True},
]
tool_input = {"file_path":"'"$REC"'","edits":edits}
payload = {"tool_name":"MultiEdit","tool_input":tool_input}
print(json.dumps(payload))
')" "" "$REC" 'AAA

PLACEHOLDER

design-system source paths: PLACEHOLDER'
run_raw deny "MultiEdit per-edit replace_all:false on the load-bearing edit leaves label paragraph unresolved" \
  "$(python3 -c '
import json
edits = [
  {"old_string":"AAA","new_string":"ok","replace_all":True},
  {"old_string":"PLACEHOLDER","new_string":"src/tokens/color.json","replace_all":False},
]
tool_input = {"file_path":"'"$REC"'","edits":edits}
payload = {"tool_name":"MultiEdit","tool_input":tool_input}
print(json.dumps(payload))
')" "" "$REC" 'AAA

PLACEHOLDER

design-system source paths: PLACEHOLDER'
run_raw deny "MultiEdit fails closed when an edit old_string is absent" \
  "$(python3 -c '
import json
edits = [{"old_string":"NOPE","new_string":"x","replace_all":True}]
tool_input = {"file_path":"'"$REC"'","edits":edits}
payload = {"tool_name":"MultiEdit","tool_input":tool_input}
print(json.dumps(payload))
')" "" "$REC" 'some content with no matching token'

# --- group 3: malformed JSON on stdin --------------------------------------
mark malformed-json
run_raw deny "truncated JSON on stdin denies" '{"tool_name":"Write","tool_input":{'
run_raw deny "non-object JSON on stdin denies" '"just a string"'
run_raw deny "empty payload on stdin denies" ''

# --- group 4: kill-switch unrecognized value stays ACTIVE ------------------
mark kill-switch
td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/docs/issue-10/reports"
printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":"no label here"}}' "$REC" \
  | env CLAUDE_PROJECT_DIR="$td" BRAND_DESIGN_SYSTEM_HANDOFF_GATE_OFF=banana /bin/bash "$GATE" >/dev/null 2>&1
rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
rm -rf "$td"
report deny "$got" "kill-switch=banana (unrecognized) stays ACTIVE"

td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/docs/issue-10/reports"
printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":"no label here"}}' "$REC" \
  | env CLAUDE_PROJECT_DIR="$td" BRAND_DESIGN_SYSTEM_HANDOFF_GATE_OFF=1 /bin/bash "$GATE" >/dev/null 2>&1
rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
rm -rf "$td"
report allow "$got" "kill-switch=1 (recognized on-spelling) disables"

# --- group 5: absolute / ./-prefixed file_path reaches same record --------
mark absolute-path
td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/docs/issue-10/reports"
printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":%s}}' \
  "$td/$REC" "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "no label here at all")" \
  | env CLAUDE_PROJECT_DIR="$td" /bin/bash "$GATE" >/dev/null 2>&1
rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
rm -rf "$td"
report deny "$got" "absolute file_path reaches same record as relative"

td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/docs/issue-10/reports"
printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":%s}}' \
  "./$REC" "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "no label here at all")" \
  | env CLAUDE_PROJECT_DIR="$td" /bin/bash "$GATE" >/dev/null 2>&1
rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
rm -rf "$td"
report deny "$got" "./-prefixed file_path reaches same record as relative"

# --- group 6: non-Write/Edit/MultiEdit tool is out of scope ----------------
mark non-write-tool
run_raw allow "Bash tool call is out of scope (exit 0)" \
  '{"tool_name":"Bash","tool_input":{"command":"echo hi"}}'

# --- group 7: missing-core -> guarded source must deny, not allow ---------
# Modeled on core's own run-gate-lib-tests.sh pattern (~line 230-241):
# point CLAUDE_PLUGIN_ROOT_CORE at a nonexistent directory so the `||`
# guard added around the gate-lib.sh source line fires, and confirm the
# gate fails closed (exit 2) rather than silently allowing.
mark missing-core
td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/docs/issue-10/reports"
printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":%s}}' \
  "$REC" "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' 'design-system source paths: src/tokens/color.json')" \
  | env CLAUDE_PROJECT_DIR="$td" CLAUDE_PLUGIN_ROOT_CORE="$td/no-such-core" /bin/bash "$GATE" >/dev/null 2>&1
rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
rm -rf "$td"
report deny "$got" "CLAUDE_PLUGIN_ROOT_CORE pointed nowhere denies (guarded gate-lib.sh source, not silent-allow)"

printf '\n== %d passed, %d failed ==\n' "$pass" "$fail"
echo "mandatory groups exercised:$groups_seen"
for g in replace_all-edit multiedit-replace_all malformed-json kill-switch absolute-path non-write-tool missing-core; do
  case " $groups_seen " in
    *" $g "*) ;;
    *) echo "MANDATORY GROUP MISSING: $g" >&2; fail=$((fail + 1)) ;;
  esac
done
[ "$fail" -eq 0 ]
