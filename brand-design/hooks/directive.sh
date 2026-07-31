#!/usr/bin/env bash
. "${CLAUDE_PLUGIN_ROOT_CORE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd -P)}/hooks/lib/role-directive.sh"
YOU_DECIDE="YOU DECIDE: 브랜드 정체성이 시각적으로 일관되는가"
USE_WHEN="USE_WHEN: 브랜드 자산 신설/변경이 걸릴 때"
PRODUCES="PRODUCES (required record fields): brand guide entry (logo usage rule if applicable, exact color values, typography role, voice/tone note if copy present, imagery style note if applicable, do's/don'ts), asset spec (exact values applied + file formats/paths), consistency check vs existing guide (checklist pass/fail incl. WCAG 4.5:1/3:1 contrast result), design-system source paths"
HAND_OFF="HAND-OFF: 토큰 시스템화 구현은 → ux-engineering"
core_role_directive "$YOU_DECIDE" "$USE_WHEN" "$PRODUCES" "$HAND_OFF"
