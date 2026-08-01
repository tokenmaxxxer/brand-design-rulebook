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
pass=0; fail=0
report() { if [ "$2" = "$1" ]; then pass=$((pass+1)); printf 'ok     %-50s %s\n' "$3" "$2"; else fail=$((fail+1)); printf 'FAIL   %-50s want=%s got=%s\n' "$3" "$1" "$2"; fi; }

groups_seen=""
mark() { groups_seen="$groups_seen $1"; }

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
run allow design-system-paths-present "$REC" 'design-system source paths: ux-engineering/tokens/color.json, ux-engineering/tokens/spacing.json'
run allow foreign-path "docs/issue-10/reports/qa.md" "x"
run allow not-applicable-allowance "$REC" 'design-system source paths: not applicable — no new pairing introduced this phase.'

CONTENT_GOOD='design-system source paths: ux-engineering/tokens/color.json

## other section
some/other/path.json'

# --- group 1: Edit replace_all: true against multiply-occurring old_string
mark replace_all-edit
run_raw allow "Edit replace_all:true reflects full replacement (label present)" \
  "$(python3 -c '
import json
old = json.dumps("XXX")
new = json.dumps("design-system source paths: ux-engineering/tokens/color.json")
tool_input = {"file_path":"'"$REC"'","old_string":"XXX","new_string":"design-system source paths: ux-engineering/tokens/color.json","replace_all":True}
payload = {"tool_name":"Edit","tool_input":tool_input}
print(json.dumps(payload))
')" "" "$REC" 'XXX

XXX

XXX'
run_raw deny "Edit replace_all:false leaves other occurrences unlabeled (first-only, no label reached)" \
  "$(python3 -c '
import json
tool_input = {"file_path":"'"$REC"'","old_string":"YYY","new_string":"plain prose no label","replace_all":False}
payload = {"tool_name":"Edit","tool_input":tool_input}
print(json.dumps(payload))
')" "" "$REC" 'YYY

more unrelated text'

# --- group 2: MultiEdit with mixed replace_all true/false in one call -----
mark multiedit-replace_all
run_raw allow "MultiEdit mixed replace_all true/false yields passing record" \
  "$(python3 -c '
import json
edits = [
  {"old_string":"AAA","new_string":"design-system source paths: ux-engineering/tokens/color.json","replace_all":True},
  {"old_string":"BBB","new_string":"kept once","replace_all":False},
]
tool_input = {"file_path":"'"$REC"'","edits":edits}
payload = {"tool_name":"MultiEdit","tool_input":tool_input}
print(json.dumps(payload))
')" "" "$REC" 'AAA

BBB
BBB'
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

printf '\n== %d passed, %d failed ==\n' "$pass" "$fail"
echo "mandatory groups exercised:$groups_seen"
for g in replace_all-edit multiedit-replace_all malformed-json kill-switch absolute-path non-write-tool; do
  case " $groups_seen " in
    *" $g "*) ;;
    *) echo "MANDATORY GROUP MISSING: $g" >&2; fail=$((fail + 1)) ;;
  esac
done
[ "$fail" -eq 0 ]
