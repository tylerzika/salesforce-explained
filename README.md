# Salesforce Explained

Contains context for an agent or programmer in acquiring general Salesforce
technical knowledge from a Software Engineering perspective.

# Getting Started

Create a Developer Sandbox from Trailhead. Deploy via the Salesforce CLI. Scratch Org supported.

# Apex

Salesforce's propritary programming language. A list off all ways it can run: APEX_EXECUTION_CONTEXT_TODO.md

Sign-off script split:

- `scripts/apex/campaign-member.apex` creates/updates records.
- `scripts/apex/campaign-member-cleanup.apex` deletes those records for a clean rerun.
- `scripts/apex/campaign-member-limit-bot.apex` intentionally exceeds one governor limit to stress test the same transaction model.

## Governor Limit Chaos Run

Use the chaos harness when you want LIMIT-BOT to intentionally cross a hard governor boundary.

1. Open `scripts/apex/campaign-member-limit-bot.apex` and set `limitMode` to one of:
   - `SOQL_QUERIES`
   - `DML_STATEMENTS`
   - `DML_ROWS`
2. Run:

```bash
HOME=/tmp SF_USE_GENERIC_UNIX_KEYCHAIN=true sf apex run \
  --target-org <your-org-alias> \
  --file scripts/apex/campaign-member-limit-bot.apex
```

Expected result: `System.LimitException` and rollback of that anonymous transaction.

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
- CLRS (3rd ed.) Ch.2 loop invariants (for proving logging/state properties)

## Third Discipline: Symbolic Transformation

There is now a third conceptual lane in this repo alongside the earlier TAOCP and
SICP references:

- `TAOCP`: representation, control, instrumentation, and measurable behavior.
- `SICP`: abstraction barriers, composition, and execution-environment mental models.
- `Symbolic Transformation`: shaping meaning-bearing text into operational structure.

In older programming conversations this might have been dismissed as "string
manipulation." With built-in LLM access in Apex, it becomes more serious:

- prompts act like program inputs
- schemas act like contracts
- evidence packets act like structured symbolic payloads
- model outputs become intermediate representations that Apex can validate,
  route, reject, or persist

The important shift is that text is no longer just presentation. In many flows
it is now part of the computational substrate.

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
