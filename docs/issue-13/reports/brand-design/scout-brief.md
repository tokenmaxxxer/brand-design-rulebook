# issue-13 scout: skip record

Scouting skipped. Condition met: "the spec literally leaves no design
decision open" — issue-13's own precondition names the single
authoritative reference (`core` issue #72's gate-house standard,
`core/hooks/lib/gate-lib.sh`/`gate-lib.py` + their handbook and test
harness), and the mandate is reference-adopt, not independent design
("자체 재구현 금지"). There is no exemplar field to compare against: the
correct shape is fixed by that one upstream canon, already pulled in
full via `gh api` (see survey.md's "What core already provides"). Any
sweep across other rulebooks' gate implementations would only be looking
for the same canon's usage pattern, which the handbook's own "Per-repo
migration checklist" already specifies step-by-step — re-deriving it via
search would violate the "자체 재구현 금지" instruction, not fulfill it.
