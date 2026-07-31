#!/usr/bin/env bash
. "${CLAUDE_PLUGIN_ROOT_CORE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd -P)}/hooks/lib/role-directive.sh"
YOU_DECIDE="YOU DECIDE: 브랜드 정체성이 시각적으로 일관되는가"
USE_WHEN="USE_WHEN: 브랜드 자산 신설/변경이 걸릴 때"
PRODUCES="PRODUCES (required record fields): brand guide entry, asset spec, consistency check vs existing guide, design-system source paths"
HAND_OFF="HAND-OFF: 토큰 시스템화 구현은 → ux-engineering"
core_role_directive "$YOU_DECIDE" "$USE_WHEN" "$PRODUCES" "$HAND_OFF"
