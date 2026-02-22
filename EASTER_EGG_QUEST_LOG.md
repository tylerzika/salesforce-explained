# Easter Egg Quest Log

This quest log turns every in-code comment breadcrumb into a playable checklist.

## Scope

- Included files: `force-app/main/default/classes/*.cls`, `force-app/main/default/triggers/*.trigger`, `scripts/apex/*.apex`
- Included clues: every source line that starts with `//`, `/*`, or `*`
- Excluded on purpose: extracted manuals in `official-docs/` and Markdown prose files

## Quest Rules

1. Pick a quest file below.
2. Read every clue (all are exact comment lines from source).
3. Perform the objective and verify the done condition.
4. Check the quest as complete in your own runbook when done.

## Quest 01: The Handler Split

**File:** `force-app/main/default/classes/AccountTriggerHandler.cls`
**Objective:** Explain how this handler separates orchestration, side effects, and transition-aware domain logging.
**Clues:**
- `force-app/main/default/classes/AccountTriggerHandler.cls:2` // SICP hint: keep composition small and explicit; handlers build names via
- `force-app/main/default/classes/AccountTriggerHandler.cls:3` // tiny pure helpers while side effects stay in one place.
- `force-app/main/default/classes/AccountTriggerHandler.cls:4` // Role prep (Platform Engineer): preserve bulk safety by iterating Trigger.new
- `force-app/main/default/classes/AccountTriggerHandler.cls:5` // once and avoiding queries in per-record loops.
- `force-app/main/default/classes/AccountTriggerHandler.cls:6` // Role prep (Solution Architect): keep domain logic in handlers and keep
- `force-app/main/default/classes/AccountTriggerHandler.cls:7` // triggers as orchestration points only.
- `force-app/main/default/classes/AccountTriggerHandler.cls:30` // TAOCP easter egg: stable key order makes log scans feel like orderly runs.
- `force-app/main/default/classes/AccountTriggerHandler.cls:32` // Field-level breadcrumbs support quicker triage in production debugging.
- `force-app/main/default/classes/AccountTriggerHandler.cls:45` // Architect mindset: include both previous and current values when the
- `force-app/main/default/classes/AccountTriggerHandler.cls:46` // business process depends on transitions, not just end state.
**Done When:** You can point to where handler responsibilities end and trigger responsibilities begin.

## Quest 02: The Executable Spec

**File:** `force-app/main/default/classes/AccountTriggerHandlerTest.cls`
**Objective:** Verify that the tests codify behavior contracts for insert, update, bulk, and monotonic counter invariants.
**Clues:**
- `force-app/main/default/classes/AccountTriggerHandlerTest.cls:3` // Role prep (Platform Engineer): tests should assert behavior contracts, not
- `force-app/main/default/classes/AccountTriggerHandlerTest.cls:4` // implementation details, so refactors remain safe.
- `force-app/main/default/classes/AccountTriggerHandlerTest.cls:5` // Role prep (Solution Architect): this suite is the executable specification
- `force-app/main/default/classes/AccountTriggerHandlerTest.cls:6` // for Account trigger semantics and observability.
- `force-app/main/default/classes/AccountTriggerHandlerTest.cls:90` // Insert path verifies both trigger-level and handler-level instrumentation.
- `force-app/main/default/classes/AccountTriggerHandlerTest.cls:160` // Transition assertions protect revenue logic against silent regressions.
- `force-app/main/default/classes/AccountTriggerHandlerTest.cls:196` // Bulk tests are your governor-limit safety net.
- `force-app/main/default/classes/AccountTriggerHandlerTest.cls:234` // CLRS-style invariant: counters should never decrease within one execution context.
- `force-app/main/default/classes/AccountTriggerHandlerTest.cls:288` // Companion proof: AFTER_* for one DML unit can be followed by more work.
**Done When:** You can summarize which regression each test block is preventing.

## Quest 03: The Context Atlas

**File:** `force-app/main/default/classes/TriggerContextInspector.cls`
**Objective:** Describe how structured context snapshots form an observability contract.
**Clues:**
- `force-app/main/default/classes/TriggerContextInspector.cls:2` // SICP-flavored instrumentation: snapshot the "environment" (trigger context)
- `force-app/main/default/classes/TriggerContextInspector.cls:3` // so behavior can be reasoned about from data, not only from control flow.
- `force-app/main/default/classes/TriggerContextInspector.cls:4` // TAOCP-flavored note: this is our compact state table for one event.
- `force-app/main/default/classes/TriggerContextInspector.cls:5` // Role prep (Platform Engineer): prefer structured payloads over ad-hoc
- `force-app/main/default/classes/TriggerContextInspector.cls:6` // strings so tests and log parsers stay reliable.
- `force-app/main/default/classes/TriggerContextInspector.cls:7` // Role prep (Solution Architect): this method is an observability boundary;
- `force-app/main/default/classes/TriggerContextInspector.cls:8` // changes here can impact dashboards, alerting, and support runbooks.
**Done When:** You can name downstream consumers that would break if payload shape drifts.

## Quest 04: The Monotonic Counter

**File:** `force-app/main/default/classes/TriggerEventLogger.cls`
**Objective:** Prove that class `static` state is transaction-scoped and monotonic within one execution context.
**Clues:**
- `force-app/main/default/classes/TriggerEventLogger.cls:6` // Knuth lane marker: TAOCP Vol. 1 starts with program composition from
- `force-app/main/default/classes/TriggerEventLogger.cls:7` // algorithms + data structures. Here, the structure is a class static counter.
- `force-app/main/default/classes/TriggerEventLogger.cls:8` // SICP lane marker: this is state in one environment frame (execution context),
- `force-app/main/default/classes/TriggerEventLogger.cls:9` // not global state across all time.
- `force-app/main/default/classes/TriggerEventLogger.cls:10` // Transaction-scoped state: this value persists across all trigger/code-unit
- `force-app/main/default/classes/TriggerEventLogger.cls:11` // invocations inside one Apex execution context, then resets next transaction.
- `force-app/main/default/classes/TriggerEventLogger.cls:12` // Role prep (Platform Engineer): use transaction-local statics for recursion
- `force-app/main/default/classes/TriggerEventLogger.cls:13` // guards and diagnostic counters, not as durable storage.
- `force-app/main/default/classes/TriggerEventLogger.cls:14` // Role prep (Solution Architect): define a shared logging contract so every
- `force-app/main/default/classes/TriggerEventLogger.cls:15` // domain trigger emits comparable telemetry.
- `force-app/main/default/classes/TriggerEventLogger.cls:17` // Change for Jim: reveal hidden cross-object rhythm inside one transaction.
- `force-app/main/default/classes/TriggerEventLogger.cls:18` // Final sign-off note: validated from logs with stable signature counts
- `force-app/main/default/classes/TriggerEventLogger.cls:19` // (Account=4, Campaign=4, Contact=2, Opportunity=2, CampaignMember=2).
- `force-app/main/default/classes/TriggerEventLogger.cls:20` // CLRS Ch.2 lens: within one execution context, logCalls and per-object calls
- `force-app/main/default/classes/TriggerEventLogger.cls:21` // should remain monotonic non-decreasing after each log() call.
- `force-app/main/default/classes/TriggerEventLogger.cls:35` // Keep logger side effects lightweight: no SOQL, no DML, no callouts.
- `force-app/main/default/classes/TriggerEventLogger.cls:55` // Platform habit: turn runtime context into structured data first, then log.
- `force-app/main/default/classes/TriggerEventLogger.cls:62` // Test seam: expose counter state so invariants can be asserted directly.
**Done When:** You can explain why counter growth across different triggers is expected in one anonymous Apex run.

## Quest 05: The Account Dispatcher

**File:** `force-app/main/default/triggers/AccountTrigger.trigger`
**Objective:** Trace how trigger context is decoded and routed to handler behavior.
**Clues:**
- `force-app/main/default/triggers/AccountTrigger.trigger:10` // Dispatcher pattern (SICP 2.4.x vibes): decode context, route to behavior.
- `force-app/main/default/triggers/AccountTrigger.trigger:11` // Role prep (Platform Engineer): one trigger per object avoids execution-order
- `force-app/main/default/triggers/AccountTrigger.trigger:12` // ambiguity and simplifies incident debugging.
- `force-app/main/default/triggers/AccountTrigger.trigger:13` // Role prep (Solution Architect): the trigger is an API boundary for all
- `force-app/main/default/triggers/AccountTrigger.trigger:14` // automations touching Account; keep policy decisions in handlers/services.
**Done When:** You can identify where to add new Account policy without bloating the trigger.

## Quest 06: The Campaign Signal

**File:** `force-app/main/default/triggers/CampaignTrigger.trigger`
**Objective:** Tie campaign events to attribution-focused telemetry in the shared log stream.
**Clues:**
- `force-app/main/default/triggers/CampaignTrigger.trigger:10` // Campaign attribution path marker: this event feeds the same transaction log stream.
- `force-app/main/default/triggers/CampaignTrigger.trigger:11` // Role prep: campaign-side telemetry helps attribution and pipeline explainability.
**Done When:** You can explain why campaign events belong in the same transaction narrative as account/opportunity changes.

## Quest 07: The Member Wave

**File:** `force-app/main/default/triggers/CampaignMemberTrigger.trigger`
**Objective:** Validate bulk behavior and volume visibility for campaign member upserts.
**Clues:**
- `force-app/main/default/triggers/CampaignMemberTrigger.trigger:10` // SICP stream wink: two members in one upsert still flow through one transaction.
- `force-app/main/default/triggers/CampaignMemberTrigger.trigger:11` // Role prep: member-volume events are where bulk limits usually show up first.
**Done When:** You can map Trigger.new size to observed log behavior for campaign members.

## Quest 08: The Contact Echo

**File:** `force-app/main/default/triggers/ContactTrigger.trigger`
**Objective:** Keep the lightweight trigger pattern consistent outside the Account domain.
**Clues:**
- `force-app/main/default/triggers/ContactTrigger.trigger:10` // Minimal trigger, maximum signal: TAOCP style "measure first, optimize later."
- `force-app/main/default/triggers/ContactTrigger.trigger:11` // Role prep: keep non-Account objects on the same pattern for consistency.
**Done When:** You can describe one consistency rule that all non-Account triggers should follow.

## Quest 09: The Opportunity Thread

**File:** `force-app/main/default/triggers/OpportunityTrigger.trigger`
**Objective:** Connect opportunity path logic with forecast-impact observability.
**Clues:**
- `force-app/main/default/triggers/OpportunityTrigger.trigger:10` // Opportunity path: data and control travel together through one execution frame.
- `force-app/main/default/triggers/OpportunityTrigger.trigger:11` // Role prep: this stream is where forecast-impacting logic should stay observable.
**Done When:** You can show where forecast-related behavior remains visible in logs.

## Quest 10: The Seed Run

**File:** `scripts/apex/campaign-member.apex`
**Objective:** Use the idempotent seed script to generate a multi-object, single-transaction trace.
**Clues:**
- `scripts/apex/campaign-member.apex:1` // Agentforce Sales core data slice:
- `scripts/apex/campaign-member.apex:2` // Account -> Contact -> Opportunity plus Campaign/CampaignMember attribution.
- `scripts/apex/campaign-member.apex:3` // This script intentionally creates data that exercises multiple trigger paths
- `scripts/apex/campaign-member.apex:4` // in one execution context (anonymous Apex transaction).
- `scripts/apex/campaign-member.apex:5` // TAOCP easter egg: one transaction, many operations, one evolving state table.
- `scripts/apex/campaign-member.apex:6` // SICP easter egg: the data model is the abstraction boundary; DML is the evaluator.
- `scripts/apex/campaign-member.apex:7` // Role prep (Platform Engineer now): treat this file as an idempotent seed
- `scripts/apex/campaign-member.apex:8` // script for repeatable debugging and demo scenarios.
- `scripts/apex/campaign-member.apex:9` // Role prep (Solution Architect in 2 years): this object graph models core
- `scripts/apex/campaign-member.apex:10` // lead-to-revenue entities and their attribution links.
- `scripts/apex/campaign-member.apex:11` // Final sign-off: this file is now create/upsert only.
- `scripts/apex/campaign-member.apex:12` // Teardown lives in scripts/apex/campaign-member-cleanup.apex.
- `scripts/apex/campaign-member.apex:210` // Each DML operation can fire before/after triggers.
- `scripts/apex/campaign-member.apex:211` // TriggerEventLogger.logCalls (a class static) keeps incrementing through all
- `scripts/apex/campaign-member.apex:212` // these trigger invocations because they run in the same transaction.
- `scripts/apex/campaign-member.apex:213` // Literal page nods (edition-sensitive): TAOCP Vol. 1 p.1, SICP p.1.
- `scripts/apex/campaign-member.apex:214` // Integration mindset: External_ID__c-based upserts make reruns deterministic.
- `scripts/apex/campaign-member.apex:361` // Bulk upsert of two members, so Trigger.new size is 2 in CampaignMember trigger.
- `scripts/apex/campaign-member.apex:362` // SICP 3.x wink: sequence matters because side effects (trigger logs) are observed.
**Done When:** You can run this script repeatedly and get deterministic records plus explainable trigger traces.

## Quest 11: The Cleanup Ritual

**File:** `scripts/apex/campaign-member-cleanup.apex`
**Objective:** Reset seeded records safely while preserving relationship constraints.
**Clues:**
- `scripts/apex/campaign-member-cleanup.apex:1` // Cleanup companion to scripts/apex/campaign-member.apex.
- `scripts/apex/campaign-member-cleanup.apex:2` // Final sign-off: keep creation and teardown separate for safer reruns.
- `scripts/apex/campaign-member-cleanup.apex:3` // Run this when you want to reset the sandbox records for a fresh insert path.
- `scripts/apex/campaign-member-cleanup.apex:50` // Delete children first, then parents to avoid relationship constraints.
**Done When:** You can cleanly reset and rerun the seed flow without integrity errors.

## Coverage Check

Run this command to verify quest clues stay in sync with source comments:

```bash
rg -n "^\s*(//|/\*|\*)" force-app/main/default/classes force-app/main/default/triggers scripts/apex
```
