#!/usr/bin/env bash
. "${CLAUDE_PLUGIN_ROOT_CORE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd -P)}/hooks/lib/role-directive.sh"
# Deepened per issue-10 (docs/issue-10/proposals/
# 2026-07-31-brand-design-directive-hardening.md, section (a)). Each
# clause below is authored by the brand-design-* plugin named in the
# trailing comment; the mechanical half of the same concern is enforced
# by that plugin's own methodology-gate.sh (see sibling plugin
# directories) — this file stays the single directive.sh for the role.
YOU_DECIDE=$'YOU DECIDE: 브랜드 정체성이 시각적으로 일관되는가
SCOPE-EXCEEDED RULE: only the Kapferer Physique (visual) facet is in
scope for this role — Personality, Culture, Relationship, Reflection,
and Self-image are out of scope; a proposal or record that reaches
into any of those facets has exceeded YOU_DECIDE and must say so.
[brand-design-kapferer-scope-guard]'
USE_WHEN=$'USE_WHEN: 브랜드 자산 신설/변경이 걸릴 때
- a brand guide entry or asset spec write is expected whenever a new or
  changed brand asset (logo, color, typography, imagery, voice/tone) is
  the trigger [brand-design-guide-and-spec]'
PRODUCES=$'PRODUCES (required record fields):
- brand guide entry: every sub-field applicable to the asset class
  touched must appear with a concrete value; an inapplicable sub-field
  (e.g. no logo involved) states "not applicable: <reason>" rather than
  being omitted silently [brand-design-guide-and-spec]
- asset spec: exact values applied (hex/RGB, not swatch name) plus file
  formats/paths — restating the rule instead of the applied value is a
  fail [brand-design-guide-and-spec]
- consistency check vs existing guide: a named per-item pass/fail plus
  one consolidated verdict — a prose paragraph with no itemization is a
  fail regardless of content quality [brand-design-wcag-consistency]
- WCAG contrast: an actual ratio number with pass/fail against 4.5:1
  (normal) or 3:1 (large); "looks fine" or omission is a fail
  [brand-design-wcag-consistency]
- design-system source paths: literal repo paths, not a description of
  what ux-engineering "should" build [brand-design-system-handoff]
PROHIBITIONS (phase-2 records must acknowledge each as not-triggered or
how it was avoided): no undocumented color/font introduced silently; no
WCAG number omitted or replaced with "looks fine"; no token-
systemization work performed by this role [brand-design-kapferer-scope-guard]'
HAND_OFF="HAND-OFF: 토큰 시스템화 구현은 → ux-engineering. If the work in front of you drifts outside the YOU DECIDE line above, stop and hand off per this arrow — do not silently absorb another role's scope; record the hand-off point in this role's record before opening the next role's session. [brand-design-system-handoff]"
core_role_directive "$YOU_DECIDE" "$USE_WHEN" "$PRODUCES" "$HAND_OFF"
