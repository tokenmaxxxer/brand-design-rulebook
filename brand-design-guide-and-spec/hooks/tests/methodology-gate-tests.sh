#!/usr/bin/env bash
# Real-subprocess gate tests for brand-design-guide-and-spec's
# methodology-gate.sh. Modeled on implementation-rulebook/tests/
# run-gate-tests.sh's shape, extended (issue-13 remediation) with the six
# mandatory case groups run-gate-lib-tests.sh requires of any gate migrated
# to the gate-house standard (core issue #72):
#
#   1. Edit with replace_all: true against a multiply-occurring old_string.
#   2. MultiEdit with a mix of replace_all true/false edits in one call.
#   3. Malformed JSON payload (truncated, non-object, empty).
#   4. Kill-switch set to an unrecognized value -> must stay ACTIVE.
#   5. Absolute file_path (and ./-prefixed) reaching the same record a
#      relative-path fixture already reaches.
#   6. A Bash-tool call whose target isn't Write/Edit/MultiEdit -> gate is
#      out of scope, exits 0 (documents current behavior explicitly).
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
report() { if [ "$2" = "$1" ]; then pass=$((pass+1)); printf 'ok     %-34s %s\n' "$3" "$2"; else fail=$((fail+1)); printf 'FAIL   %-34s want=%s got=%s\n' "$3" "$1" "$2"; fi; }

REC=docs/issue-10/reports/brand-design.md

# --- static: hooks.json PreToolUse matcher covers every tool-name literal
# methodology-gate.sh branches on (regression guard, modeled on
# brand-design-wcag-consistency's hooks/tests/methodology-gate-tests.sh
# static check). No violation today. ---
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
  found=0
  for alt in "${matcher_alts[@]}"; do
    [ "$alt" = "$lit" ] && found=1 && break
  done
  if [ "$found" -eq 0 ] && grep -qE "tool ==? \"$lit\"|tool_name.*\"$lit\"|\"$lit\".*tool|\(\"$lit\", \"" "$GATE"; then
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

# want name file content
run() {
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/docs/issue-10/reports"
  printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":%s},"cwd":"%s"}' \
    "$3" "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$4")" "$td" \
    | env CLAUDE_PROJECT_DIR="$td" /bin/bash "$GATE" >/dev/null 2>&1
  rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$1" "$got" "$2"
}

# Field labels must now be heading/label-shaped lines (each field on its own
# line, value in the same paragraph) per the section/adjacency upgrade.
RECORD_COMPLETE='logo usage: keep 8px clear space.

color: #1a2b3c applied to header background.

typography: heading uses Pretendard Bold.

asset spec: assets/brand/header-bg.svg applies #1a2b3c'

NOT_APPLICABLE_LOGO='not applicable: no logo asset touched in this change.

asset spec: #1a2b3c applied to header.icon-bg.svg'

run deny  brand-guide-entry-missing "$REC" 'nothing here about the brand'
run deny  asset-spec-missing "$REC" 'logo usage: keep 8px clear space.

typography: heading uses Pretendard Bold.'
run allow record-complete "$REC" "$RECORD_COMPLETE"
run allow not-applicable-logo "$REC" "$NOT_APPLICABLE_LOGO"
run allow foreign-path "docs/issue-10/reports/qa.md" "x"

# --- group: a stray pass/fail-shaped token in an UNRELATED paragraph must
# not satisfy the asset-spec check scoped to the asset-spec paragraph
# (issue-13 defect-1 regression case: no bare `\S+/\S+` fallback). ---
FALSE_POSITIVE_GUARD='logo usage: keep 8px clear space.

typography: heading uses Pretendard Bold. see docs/notes for pass/fail history.

asset spec: needs a concrete value, still pending.'
run deny asset-spec-false-positive-guard "$REC" "$FALSE_POSITIVE_GUARD"

# ---------------------------------------------------------------------------
# generic helper: post an arbitrary JSON payload (built by the caller) and
# report allow/deny/exit-N, with an optional extra env-var assignment.
# want name payload-json [env_key=val ...]
# ---------------------------------------------------------------------------
run_payload() {
  want="$1"; name="$2"; payload="$3"; shift 3
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/docs/issue-10/reports"
  out="$(printf '%s' "$payload" | env CLAUDE_PROJECT_DIR="$td" "$@" /bin/bash "$GATE" 2>&1)"
  rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$want" "$got" "$name"
}

# --- group 1: Edit with replace_all:true against a multiply-occurring
# old_string. The fixture's on-disk starting content has the asset-spec
# paragraph missing its concrete value in two places; replace_all:true must
# replace BOTH occurrences so the reconstructed text passes. ---
run_edit() { # want name starting-content old new replace_all
  want="$1"; name="$2"; start="$3"; old="$4"; new="$5"; ra="$6"
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/docs/issue-10/reports"
  fp="$td/$REC"
  printf '%s' "$start" > "$fp"
  ti="$(python3 -c 'import json,sys; o,n,ra=sys.argv[1:4]; print(json.dumps({"file_path": sys.argv[4], "old_string": o, "new_string": n, "replace_all": ra=="true"}))' "$old" "$new" "$ra" "$REC")"
  payload="$(python3 -c 'import json,sys; print(json.dumps({"tool_name":"Edit","tool_input":json.loads(sys.argv[1])}))' "$ti")"
  out="$(printf '%s' "$payload" | env CLAUDE_PROJECT_DIR="$td" /bin/bash "$GATE" 2>&1)"
  rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$want" "$got" "$name"
}

EDIT_START='logo usage: keep 8px clear space.

typography: heading uses Pretendard Bold.

asset spec: assets/PLACEHOLDER/logo.PLACEHOLDER'
run_edit allow edit-replace_all-multi-occurrence "$EDIT_START" \
  "PLACEHOLDER" "svg" "true"

# replace_all:false denies: old_string occurs twice in the asset-spec
# paragraph (once inside the path segment, once as the extension) and
# str.replace(old,new,1)-style first-occurrence-only reconstruction only
# resolves the leftmost one ("assets/svg/logo.PLACEHOLDER") — the
# extension is still the literal, unresolved "PLACEHOLDER" token, which
# matches neither PATH_OR_FORMAT_RE nor HEX_RE, so asset_spec_ok() stays
# false and the write is denied. Only replace_all:true resolves BOTH
# occurrences to "assets/svg/logo.svg", giving a real ".svg" extension
# match and an allow — proving replace_all is genuinely honored rather
# than the test being outcome-blind to it.
run_edit deny edit-replace_all-false-first-occurrence-only "$EDIT_START" \
  "PLACEHOLDER" "svg" "false"

# --- group 2: MultiEdit with a mix of replace_all true/false edits. ---
run_multiedit() { # want name starting-content edits-json
  want="$1"; name="$2"; start="$3"; edits="$4"
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/docs/issue-10/reports"
  fp="$td/$REC"
  printf '%s' "$start" > "$fp"
  payload="$(python3 -c 'import json,sys; print(json.dumps({"tool_name":"MultiEdit","tool_input":{"file_path":sys.argv[1],"edits":json.loads(sys.argv[2])}}))' "$REC" "$edits")"
  out="$(printf '%s' "$payload" | env CLAUDE_PROJECT_DIR="$td" /bin/bash "$GATE" 2>&1)"
  rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$want" "$got" "$name"
}

MULTIEDIT_START='logo usage: TBD TBD

typography: heading uses Pretendard Bold.

asset spec: PLACEHOLDER applies PLACEHOLDER'
run_multiedit allow multiedit-mixed-replace_all "$MULTIEDIT_START" \
  '[{"old_string":"TBD","new_string":"keep 8px clear space","replace_all":true},{"old_string":"PLACEHOLDER","new_string":"assets/brand/header-bg.svg","replace_all":true}]'

# --- group 3: malformed JSON on stdin -> deny, not silent allow. ---
run_payload deny malformed-json-truncated '{"tool_name":"Write"'
run_payload deny malformed-json-non-object '"just a string"'
run_payload deny malformed-json-empty ''

# --- group 4: kill-switch env var set to an unrecognized garbage value
# must stay ACTIVE (deny a would-be-denied record), not fail-open. ---
run_payload_env() { # want name payload env-assignment
  want="$1"; name="$2"; payload="$3"; envassign="$4"
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/docs/issue-10/reports"
  out="$(printf '%s' "$payload" | env CLAUDE_PROJECT_DIR="$td" "$envassign" /bin/bash "$GATE" 2>&1)"
  rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$want" "$got" "$name"
}
DENY_PAYLOAD="$(python3 -c 'import json; print(json.dumps({"tool_name":"Write","tool_input":{"file_path":"docs/issue-10/reports/brand-design.md","content":"nothing here about the brand"}}))')"
run_payload_env deny kill-switch-unrecognized-value-stays-active "$DENY_PAYLOAD" "BRAND_DESIGN_GUIDE_AND_SPEC_GATE_OFF=banana"
run_payload_env allow kill-switch-recognized-on-disables "$DENY_PAYLOAD" "BRAND_DESIGN_GUIDE_AND_SPEC_GATE_OFF=1"

# --- group 5: absolute file_path and ./-prefixed variant reach the same
# record a relative-path fixture already reaches, with identical outcome. ---
run_abspath() { # want name file-path-expr content
  want="$1"; name="$2"; content="$4"
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/docs/issue-10/reports"
  fp="$(eval echo "$3")"
  payload="$(printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":%s}}' \
    "$fp" "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$content")")"
  out="$(printf '%s' "$payload" | env CLAUDE_PROJECT_DIR="$td" /bin/bash "$GATE" 2>&1)"
  rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$want" "$got" "$name"
}
run_abspath allow absolute-path-record-complete '$td/'"$REC" "$RECORD_COMPLETE"
run_abspath allow dotslash-path-record-complete './'"$REC" "$RECORD_COMPLETE"
run_abspath deny  absolute-path-brand-guide-entry-missing '$td/'"$REC" 'nothing here about the brand'

# --- group 6: a Bash-tool call (not Write/Edit/MultiEdit) is out of this
# gate's declared scope -> exits 0, documenting current behavior. ---
BASH_PAYLOAD="$(python3 -c 'import json; print(json.dumps({"tool_name":"Bash","tool_input":{"command":"echo nothing here about the brand > docs/issue-10/reports/brand-design.md"}}))')"
run_payload allow bash-tool-out-of-scope "$BASH_PAYLOAD"

# --- group 7: missing-core -> guarded gate-lib.sh source must deny, not
# silently allow (modeled on core/hooks/tests/run-gate-lib-tests.sh's own
# missing-core case, ~line 230). Reuses record-complete's payload shape but
# points CLAUDE_PLUGIN_ROOT_CORE at a nonexistent path, so the `||` guard
# added to the gate-lib.sh source line must fire and exit 2. ---
td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/docs/issue-10/reports"
out="$(printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":%s}}' \
    "$REC" "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$RECORD_COMPLETE")" \
  | env CLAUDE_PROJECT_DIR="$td" CLAUDE_PLUGIN_ROOT_CORE="$td/no-such-core" /bin/bash "$GATE" 2>&1)"
rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
rm -rf "$td"; report deny "$got" "missing-core-gate-lib-guard-denies"

printf '\n== %d passed, %d failed ==\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
