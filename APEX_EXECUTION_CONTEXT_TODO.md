# Apex Execution Context TODO

Purpose: add one minimal, runnable example for each Apex execution context in this repo.

## Done criteria per item
- Metadata/class deploys successfully.
- One test method proves the context runs (except anonymous Apex script).
- README has a short "how to run" snippet.

## Context checklist
- [x] Database Trigger
  - Existing: `force-app/main/default/triggers/*Trigger.trigger`
  - Existing tests: `force-app/main/default/classes/AccountTriggerHandlerTest.cls`
  - TODO: add tests for non-Account triggers.

- [x] Anonymous Apex
  - Existing: `scripts/apex/campaign-member.apex`
  - Existing: `scripts/apex/campaign-member-cleanup.apex`

- [ ] `@future` async Apex
  - Add: `force-app/main/default/classes/ExecutionContextFutureDemo.cls`
  - Add test: `force-app/main/default/classes/ExecutionContextFutureDemoTest.cls`

- [ ] Queueable Apex
  - Add: `force-app/main/default/classes/ExecutionContextQueueableDemo.cls`
  - Add test: `force-app/main/default/classes/ExecutionContextQueueableDemoTest.cls`

- [ ] Scheduled Apex
  - Add: `force-app/main/default/classes/ExecutionContextScheduledDemo.cls`
  - Add test: `force-app/main/default/classes/ExecutionContextScheduledDemoTest.cls`

- [ ] Batch Apex
  - Add: `force-app/main/default/classes/ExecutionContextBatchDemo.cls`
  - Add test: `force-app/main/default/classes/ExecutionContextBatchDemoTest.cls`

- [ ] Platform Event trigger
  - Add event metadata: `force-app/main/default/objects/ExecutionContextEvent__e/ExecutionContextEvent__e.object-meta.xml`
  - Add trigger: `force-app/main/default/triggers/ExecutionContextEventTrigger.trigger`
  - Add test class for publish + trigger behavior.

- [ ] Change Data Capture trigger
  - Add trigger: `force-app/main/default/triggers/AccountChangeEventTrigger.trigger`
  - Add test class for trigger logic.
  - Org setup TODO: enable CDC for `Account` in org/scratch org.

- [ ] REST Apex web service
  - Add: `force-app/main/default/classes/ExecutionContextRestService.cls` (`@RestResource`)
  - Add test: `force-app/main/default/classes/ExecutionContextRestServiceTest.cls`

- [ ] SOAP Apex web service
  - Add: `force-app/main/default/classes/ExecutionContextSoapService.cls` (`global webservice static`)
  - Add test: `force-app/main/default/classes/ExecutionContextSoapServiceTest.cls`

- [ ] LWC calling `@AuraEnabled` Apex
  - Add service: `force-app/main/default/classes/ExecutionContextUiService.cls`
  - Add LWC bundle: `force-app/main/default/lwc/executionContextWorkbench/*`
  - Add Apex test for `ExecutionContextUiService`.

- [ ] Visualforce + controller Apex
  - Add controller: `force-app/main/default/classes/ExecutionContextVisualforceController.cls`
  - Add page: `force-app/main/default/pages/ExecutionContextWorkbench.page`
  - Add controller test class.

- [ ] Flow/Process invoking Apex
  - Add invocable class: `force-app/main/default/classes/ExecutionContextInvocable.cls`
  - Add test: `force-app/main/default/classes/ExecutionContextInvocableTest.cls`
  - Add flow metadata after creation: `force-app/main/default/flows/ExecutionContextDemo.flow-meta.xml`

- [ ] Inbound Email Service
  - Add handler: `force-app/main/default/classes/ExecutionContextInboundEmailHandler.cls`
  - Add test: `force-app/main/default/classes/ExecutionContextInboundEmailHandlerTest.cls`
  - Org setup TODO: create Email Service + address that points to handler.

- [ ] Global Apex method callable from Apex
  - Note: this is not a separate execution context by itself.
  - Add API class: `force-app/main/default/classes/ExecutionContextGlobalApi.cls` (`global static` method)
  - Add consumer test from another class to prove call pattern.

## Suggested build order
1. `@future`, Queueable, Scheduled, Batch
2. REST/SOAP services
3. UI entry points (LWC, Visualforce)
4. Flow invocable
5. Platform Event + CDC
6. Inbound Email + global API cleanup
