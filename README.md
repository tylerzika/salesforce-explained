# Salesforce Explained

Contains context for an agent or programmer in acquiring general Salesforce
technical knowledge from a Software Engineering perspective.

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
