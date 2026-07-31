#!/usr/bin/env bash
# Real-subprocess gate tests for brand-design-kapferer-scope-guard's
# methodology-gate.sh. Modeled on implementation-rulebook/tests/
# run-gate-tests.sh's shape.
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
    | env CLAUDE_PROJECT_DIR="$td" BRAND_DESIGN_KAPFERER_SCOPE_GUARD_GATE_OFF="${GATEOFF:-}" /bin/bash "$GATE" >/dev/null 2>&1
  rc="${PIPESTATUS[1]}"; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$1" "$got" "$2"
}

run deny  scope-boundary-missing "$PROPOSAL" 'This proposal covers everything about the brand.'
run allow scope-boundary-present "$PROPOSAL" 'This proposal covers only the Physique facet (Kapferer), per YOU_DECIDE.'
run deny  prohibitions-not-acknowledged "$REC" 'Work done: new color introduced.'
run allow prohibitions-acknowledged "$REC" 'Prohibitions: undocumented color not triggered; WCAG number omitted not triggered.'
run allow foreign-path "docs/issue-10/reports/qa.md" "x"
GATEOFF=1 run allow kill-switch-off "$REC" 'nothing at all'

printf '\n== %d passed, %d failed ==\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
