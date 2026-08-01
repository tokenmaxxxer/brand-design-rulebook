# brand-design-rulebook

Rulebook for the `brand-design` role (contract v3 role-handoff protocol), split off
per `docs/issue-160/proposals/role-taxonomy.md`'s round-3 promotion and
generated as skeleton scaffolding by issue-170.

- **decides**: 브랜드 정체성이 시각적으로 일관되는가
- **use_when**: 브랜드 자산 신설/변경이 걸릴 때
- **produces**: brand guide entry, asset spec, consistency check vs existing guide
- **write_scope**: design-system source paths (TBD at execution)
- **hand-off**: 토큰 시스템화 구현은 → ux-engineering

## Install

```
claude plugin marketplace add tokenmaxxxer/brand-design-rulebook
claude plugin install brand-design
```

## Layout

- `brand-design/.claude-plugin/plugin.json` — plugin manifest
- `brand-design/hooks/hooks.json` — SessionStart wiring only (role
  directive); each `brand-design-*/hooks/hooks.json` carries its own
  PreToolUse gate wiring — see below.
- `brand-design/hooks/directive.sh` — SessionStart role directive
- `brand-design-guide-and-spec/` — brand guide entry + asset spec
  presence/cross-reference gate; see its own README.
- `brand-design-kapferer-scope-guard/` — Kapferer Physique-facet scope
  acknowledgement (phase-1) and prohibitions acknowledgement (phase-2)
  gate; see its own README.
- `brand-design-system-handoff/` — design-system source-paths check +
  the ux-engineering hand-off boundary gate; see its own README.
- `brand-design-wcag-consistency/` — consistency-check + WCAG contrast
  gate; see its own README.
- `docs/specs/approvers.md` — Approve-authority allowlist (see below)

Each `brand-design-*/hooks/methodology-gate.sh` reference-adopts
`core/hooks/lib/gate-lib.sh` + `gate-lib.py`
(`docs/handbooks/gate-house-standard.md` in the `tokenmaxxxer-core` repo)
for its fail-closed trap, kill-switch, JSON parsing, path normalization,
and Write/Edit/MultiEdit reconstruction — never reimplemented locally.
Each gate's own kill switch is documented in its README (unrecognized
values leave the gate active, per `gate_kill_switch_active`'s fixed
convention).

This is scaffolding, not a finished rulebook: fill in doctrine detail,
handoff enforcement, and any role-specific progress gate before treating
it as load-bearing.
