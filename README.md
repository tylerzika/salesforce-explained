# Salesforce Explained

Contains context for an agent or programmer in acquiring general Salesforce
technical knowledge from a Software Engineering perspective.

# Getting Started

Create a Developer Sandbox from Trailhead. Make it your DevHub. Create a Scratch Org and deploy source with `sf project deploy start`

## Story: The Nimbus Trigger Tour

Think of one anonymous Apex run as one movie set.

- `TriggerEventLogger.logCalls` is the clapboard counter.
- Each trigger (`before insert`, `after insert`, per object) is a new scene.
- The counter is `static`, so it keeps counting scenes in this same execution context.
- When the movie ends (transaction boundary), the set is torn down and the counter resets.

In `scripts/apex/campaign-member.apex`, the cast is a representative Agentforce Sales
(Sales Cloud) core model:

- `Account`: Nimbus Roasters
- `Contact`: Maya Patel
- `Opportunity`: Espresso Subscription Upgrade
- `Campaign`: Q2 Webinar and Q3 Roundtable
- `CampaignMember`: Maya responding to both campaigns
- `OpportunityContactRole`: Maya as primary contact on the deal

This is why the log showed `logCalls` climbing across different triggers:
different code paths, same transaction.

Sign-off script split:
- `scripts/apex/campaign-member.apex` creates/updates records.
- `scripts/apex/campaign-member-cleanup.apex` deletes those records for a clean rerun.

## TAOCP + SICP Easter Eggs

The codebase now includes small references that map classic CS texts to Apex trigger reality:

- `force-app/main/default/classes/TriggerEventLogger.cls`:
  class-static state as transaction-scoped memory (SICP environment model vibe).
- `force-app/main/default/classes/TriggerContextInspector.cls`:
  context snapshot as a compact state table (TAOCP instrumentation vibe).
- `force-app/main/default/classes/AccountTriggerHandler.cls`:
  helper extraction to keep side effects and composition separate.
- `scripts/apex/campaign-member.apex`:
  Agentforce Sales data slice with explicit transaction-semantics comments.

Literal page nods were added as easter eggs and are edition-sensitive:

- TAOCP Vol. 1 p.1
- SICP p.1

## Role Prep Notes (In-Code)

Comments in the trigger stack now include role-oriented cues:

- `force-app/main/default/classes/TriggerEventLogger.cls`
  Focus: transaction-scoped state, lightweight logging, recursion diagnostics.
- `force-app/main/default/classes/TriggerContextInspector.cls`
  Focus: structured telemetry and observability contract boundaries.
- `force-app/main/default/classes/AccountTriggerHandler.cls`
  Focus: bulk safety, orchestration separation, transition-aware domain logging.
- `force-app/main/default/classes/AccountTriggerHandlerTest.cls`
  Focus: behavior contracts and bulk regression coverage.
- `scripts/apex/campaign-member.apex`
  Focus: idempotent seed data and lead-to-revenue object graph literacy.

## Test-Driven Development in This Repo

Use this trigger architecture as a TDD lab:

1. Write one failing test that names one behavior.
2. Implement the smallest production change to make that test pass.
3. Refactor names, extraction boundaries, and duplication.
4. Repeat with the next behavior.

### Current TDD Slice

The first test slice is in:

- `force-app/main/default/classes/AccountTriggerHandlerTest.cls`

It characterizes current behavior for Account trigger flow:

- Insert emits before/after trigger events and handler events.
- Update logs old/new revenue transitions.
- Bulk insert emits one trigger-level event per phase and one handler event per
  record.

### Testability Seam

`force-app/main/default/classes/TriggerEventLogger.cls` now captures emitted
event payloads during tests (`Test.isRunningTest()`), so assertions can target
behavior rather than raw debug logs.

## Run the Tests

Authenticate an org, then run:

```bash
HOME=/tmp SF_USE_GENERIC_UNIX_KEYCHAIN=true sf apex run test \
  --target-org <your-org-alias> \
  --tests AccountTriggerHandlerTest \
  --result-format human \
  --code-coverage
```

## Next TDD Targets

- Extract event-name building into pure helper methods and test them directly.
- Add tests for other object triggers (`Contact`, `Opportunity`, `Campaign`,
  `CampaignMember`) before adding non-logging business behavior.
- Add one real domain invariant (for example, revenue policy) with
  before-update validation tests first.
