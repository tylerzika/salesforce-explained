# Salesforce Explained

Contains context for an agent or programmer in acquiring general Salesforce
technical knowledge from a Software Engineering perspective.

# Getting Started

Create a Developer Sandbox from Trailhead. Deploy via the Salesforce CLI. Scratch Org supported.

# Deployment Steps

Install the unlocked packages first, then deploy the unpackaged learning
assets. Order matters: `test-data-sales` depends on `models`, and `force-app`
compiles against classes from both `base` and `models`.

```bash
sf org create scratch --definition-file config/project-scratch-def.json \
  --alias scratchOrgName --set-default --duration-days 7 --wait 15

sf package install -p base@0.1.0-2 -o scratchOrgName -w 10
sf package install -p models@0.1.0-1 -o scratchOrgName -w 10
sf package install -p test-data-sales@0.1.0-2 -o scratchOrgName -w 10

sf project deploy start --source-dir force-app -o scratchOrgName
```

Current version aliases live in `sfdx-project.json` under `packageAliases`.
The `models` package (ModelsApiService) requires the Einstein features from
`config/project-scratch-def.json`; `test-data-sales` won't install without
`models` already present.

## Health Cloud (`test-data-health`)

`test-data-health` generates LLM-backed Health Cloud test data. It ships a
**Health Test Data** app whose page has one LWC card per Health Cloud object —
Patient (Person Account), HealthcareProvider, CareProgram — each with a button
that calls Apex, asks the Models API for a realistic fictional record, and
inserts it. Same shape as `test-data-sales`, and like it, this package depends
only on `models`.

Health Cloud is enabled by **scratch-org features, not a managed-package
install**. `config/healthcloud-scratch-def.json` adds `HealthCloudAddOn`,
`HealthCloudUser`, `ContactsToMultipleAccounts`, and `PersonAccounts` on top of
the Einstein features that `models` needs, so org creation delivers the whole
Health Cloud data model. There is no Health Cloud `04t` to install or declare.

```bash
# 1. Create the org (this is what turns Health Cloud on)
sf org create scratch --definition-file config/healthcloud-scratch-def.json \
  --alias health --set-default --duration-days 7 --wait 15

# 2. Install the dependency first, then the package
sf package install -p models@0.1.0-1 -o health -w 10
sf package install -p test-data-health@0.1.0-1 -o health -w 10

# 3. Grant yourself Apex + tab access, then open the app
sf org assign permset --name Health_Test_Data -o health
sf org open -o health --path lightning/n/Health_Test_Data
```

`base` is not required here — `test-data-health` declares `models` as its only
dependency, and `sf package install` does not resolve dependencies for you, so
`models` must go in first.

To iterate on the source instead of installing the built version, deploy the
package directory directly (`sf project deploy start --source-dir
test-data-health -o health`) — but don't mix that with an installed version of
the same package in one org.

Note: each generate button runs one Models API callout then a DML insert, so a
factory can be called once per transaction (callout-after-DML rule). One click =
one record = one transaction. Generating many records in a single transaction
would need the callouts batched ahead of the DML, or a Queueable chain.

# Apex

Salesforce's proprietary programming language. A list of all ways it can run: APEX_EXECUTION_CONTEXT_TODO.md

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
- `force-app/main/default/classes/TA_AccountRevenueLog.cls`:
  helper extraction to keep side effects and composition separate
  (successor to the retired `AccountTriggerHandler` after the Trigger
  Actions Framework migration).
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
- `force-app/main/default/classes/TA_AccountRevenueLog.cls`
  Focus: bulk safety, orchestration separation, transition-aware domain logging.
- `force-app/main/default/classes/TA_AccountRevenueLogTest.cls`
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

- `force-app/main/default/classes/TA_AccountRevenueLogTest.cls`

It characterizes current behavior for Account trigger flow:

- Insert emits before/after telemetry-action events and revenue-action events.
- Update logs old/new revenue transitions.
- Bulk insert emits one telemetry-action event per phase and one revenue-action
  event per record.
- Direct action invocation and `MetadataTriggerHandler.bypass` exercise the
  Trigger Actions Framework seams without DML-only coupling.

### Testability Seam

`force-app/main/default/classes/TriggerEventLogger.cls` now captures emitted
event payloads during tests (`Test.isRunningTest()`), so assertions can target
behavior rather than raw debug logs.

## Run the Tests

Authenticate an org, then run:

```bash
HOME=/tmp SF_USE_GENERIC_UNIX_KEYCHAIN=true sf apex run test \
  --target-org <your-org-alias> \
  --tests TA_AccountRevenueLogTest \
  --result-format human \
  --code-coverage
```

## Next TDD Targets

- Extract event-name building into pure helper methods and test them directly.
- Add tests for other object triggers (`Contact`, `Opportunity`, `Campaign`,
  `CampaignMember`) before adding non-logging business behavior.
- Add one real domain invariant (for example, revenue policy) with
  before-update validation tests first.
