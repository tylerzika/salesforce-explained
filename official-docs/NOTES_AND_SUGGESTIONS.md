# Official Docs Notes and Suggestions

Last updated: 2026-02-22  
Editor/model log: GPT-5 (Codex)

## Notes for This Workspace
- For Apex trigger architecture work, start with `apex_developer_guide_extracted.txt` and anchor on transaction semantics before implementation details.
- The most reusable section for current repo behavior is the static-variable scope explanation:
  - class static state is transaction-scoped,
  - it persists across multiple trigger invocations in one transaction,
  - and resets across transaction boundaries.
- For Sales domain modeling and demo scripts, use `SALES_CLOUD_README.md` first, then dive into `sales_core_extracted.txt`.

## Practical Suggestions
- Keep a short "high-value anchor list" inside docs (line pointers or headings) for frequently referenced concepts:
  - Apex transaction boundaries,
  - static variable scope,
  - trigger execution/log interpretation,
  - campaign influence + opportunity attribution model.
- Add one "core object graph" reference page that maps Account/Contact/Campaign/Opportunity/CampaignMember relationships to common implementation patterns.
- Maintain an "edition-sensitive references" note for page citations (TAOCP/SICP style references are good memory aids but should be labeled as edition-dependent).

## Suggested Next Documentation Additions
- A local `official-docs/APEX_TRIGGER_PLAYBOOK.md` with:
  - trigger design rules,
  - recursion guard patterns,
  - observability standards,
  - test strategy checklist.
- A local `official-docs/SALES_OBJECT_GRAPH.md` with:
  - canonical lead-to-revenue paths,
  - attribution joins,
  - common failure/duplication points.
