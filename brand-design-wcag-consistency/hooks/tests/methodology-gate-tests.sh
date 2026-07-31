#!/usr/bin/env bash
# Real-subprocess gate tests for brand-design-wcag-consistency's
# methodology-gate.sh. Modeled on implementation-rulebook/tests/
# run-gate-tests.sh's shape.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
GATE="$HERE/../methodology-gate.sh"
pass=0; fail=0
report() { if [ "$2" = "$1" ]; then pass=$((pass+1)); printf 'ok     %-34s %s\n' "$3" "$2"; else fail=$((fail+1)); printf 'FAIL   %-34s want=%s got=%s\n' "$3" "$1" "$2"; fi; }

REC=docs/issue-10/reports/brand-design.md
run() { # want name file content
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/docs/issue-10/reports"
  printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":%s},"cwd":"%s"}' \
    "$3" "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$4")" "$td" \
    | env CLAUDE_PROJECT_DIR="$td" /bin/bash "$GATE" >/dev/null 2>&1
  rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$1" "$got" "$2"
}

run deny  wcag-number-unlabeled "$REC" 'consistency check: new text/background pairing introduced, contrast ratio measured at 4.6'
run allow no-new-pairing-early-exit "$REC" 'consistency check: no new text/background pairing introduced this change.'
run allow wcag-complete "$REC" 'consistency check: text/background pairing, contrast ratio 4.6:1, pass against AA 4.5:1.'
run allow foreign-path "docs/issue-10/reports/qa.md" "x"

printf '\n== %d passed, %d failed ==\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
