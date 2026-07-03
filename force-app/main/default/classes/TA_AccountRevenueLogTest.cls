@isTest
private class TA_AccountRevenueLogTest {
  // Executable specification for TA_AccountRevenueLog, the Trigger Actions
  // Framework port of the retired AccountTriggerHandler.
  // Role prep (Platform Engineer): tests should assert behavior contracts, not
  // implementation details, so refactors remain safe — this suite survived the
  // handler-to-action rewrite precisely because it asserts emitted events.
  // Role prep (Solution Architect): most tests run real DML so coverage
  // exercises the whole pipeline (AccountTrigger → MetadataTriggerHandler →
  // Trigger_Action__mdt rows → this action). Two tests poke the action class
  // directly, proving the framework's core win over static handler methods:
  // an action is a plain Apex object you can construct, call, and bypass.
  private static Account buildAccount(String externalId, String name, Decimal annualRevenue) {
    return new Account(External_ID__c = externalId, Name = name, AnnualRevenue = annualRevenue);
  }

  private static Map<String, Object> findEventByName(List<Map<String, Object>> events, String eventName) {
    for (Map<String, Object> eventPayload : events) {
      if (((String) eventPayload.get('eventName')) == eventName) {
        return eventPayload;
      }
    }
    System.assert(false, 'Expected event not found: ' + eventName);
    return null;
  }

  private static Map<String, Object> findEventByPrefix(List<Map<String, Object>> events, String eventNamePrefix) {
    for (Map<String, Object> eventPayload : events) {
      if (((String) eventPayload.get('eventName')).startsWith(eventNamePrefix)) {
        return eventPayload;
      }
    }
    System.assert(false, 'Expected event prefix not found: ' + eventNamePrefix);
    return null;
  }

  private static Integer countEventsByName(List<Map<String, Object>> events, String eventName) {
    Integer countValue = 0;
    for (Map<String, Object> eventPayload : events) {
      if (((String) eventPayload.get('eventName')) == eventName) {
        countValue++;
      }
    }
    return countValue;
  }

  private static Integer countEventsByPrefix(List<Map<String, Object>> events, String eventNamePrefix) {
    Integer countValue = 0;
    for (Map<String, Object> eventPayload : events) {
      if (((String) eventPayload.get('eventName')).startsWith(eventNamePrefix)) {
        countValue++;
      }
    }
    return countValue;
  }

  private static Integer firstIndexByPrefix(List<Map<String, Object>> events, String eventNamePrefix) {
    for (Integer eventIndex = 0; eventIndex < events.size(); eventIndex++) {
      if (((String) events[eventIndex].get('eventName')).startsWith(eventNamePrefix)) {
        return eventIndex;
      }
    }
    return -1;
  }

  private static String tokenValue(String eventName, String tokenName) {
    String tokenMarker = tokenName + '=';
    Integer markerIndex = eventName.indexOf(tokenMarker);
    System.assert(markerIndex >= 0, 'Expected token marker not found: ' + tokenMarker + ' in ' + eventName);

    Integer valueStart = markerIndex + tokenMarker.length();
    Integer nextTokenMarker = eventName.indexOf('_', valueStart);
    if (nextTokenMarker == -1) {
      return eventName.substring(valueStart);
    }

    return eventName.substring(valueStart, nextTokenMarker);
  }

  @testSetup
  static void seedData() {
    insert buildAccount('ACCT-TDD-SEED-UPDATE-001', 'SeedForUpdate', 1000);
  }

  @isTest
  static void insertEmitsExpectedAccountEvents() {
    // Insert path verifies both telemetry-action and revenue-action
    // instrumentation flowing through the metadata pipeline.
    TriggerEventLogger.resetCapturedEvents();

    insert buildAccount('ACCT-TDD-INSERT-001', 'TddInsert', 1500);

    List<Map<String, Object>> events = TriggerEventLogger.capturedEvents;
    System.assertEquals(4, events.size(), 'Insert should emit 4 Account events.');

    Map<String, Object> beforeInsertTelemetryEvent = findEventByName(events, 'BEFORE_INSERT');
    System.assertEquals(
      'Account',
      (String) beforeInsertTelemetryEvent.get('objectName'),
      'Expected Account objectName in payload.'
    );
    System.assertEquals(
      true,
      (Boolean) beforeInsertTelemetryEvent.get('isBefore'),
      'Expected BEFORE_INSERT event to be before-context.'
    );
    System.assertEquals(
      false,
      (Boolean) beforeInsertTelemetryEvent.get('isAfter'),
      'Expected BEFORE_INSERT event to not be after-context.'
    );
    System.assertEquals(
      true,
      (Boolean) beforeInsertTelemetryEvent.get('isInsert'),
      'Expected BEFORE_INSERT event to report insert context.'
    );
    System.assertEquals(1, (Integer) beforeInsertTelemetryEvent.get('newSize'), 'Expected Trigger.new size of 1.');
    System.assertEquals(0, (Integer) beforeInsertTelemetryEvent.get('oldSize'), 'Expected Trigger.old size of 0.');

    Map<String, Object> beforeActionEvent = findEventByPrefix(events, 'REVLOG_BEFORE_INSERT_id=');
    System.assert(
      ((String) beforeActionEvent.get('eventName')).contains('_name=TddInsert'),
      'Expected before-action event to include the Account name.'
    );

    Map<String, Object> afterActionEvent = findEventByPrefix(events, 'REVLOG_AFTER_INSERT_id=');
    String afterInsertEventName = (String) afterActionEvent.get('eventName');
    System.assert(
      afterInsertEventName.contains('_oldRevenue=null_'),
      'Expected after insert event to log null old revenue.'
    );
    System.assertEquals(
      1500,
      Decimal.valueOf(tokenValue(afterInsertEventName, 'newRevenue')),
      'Expected after insert event to log the new revenue.'
    );

    // Ordering is declared data, not code: TA_LogTriggerEvent runs at
    // Trigger_Action__mdt.Order__c = 10, TA_AccountRevenueLog at 20. Assert
    // the declared sequence so a careless metadata edit fails loudly here.
    System.assert(
      firstIndexByPrefix(events, 'BEFORE_INSERT') < firstIndexByPrefix(events, 'REVLOG_BEFORE_INSERT_id='),
      'Expected telemetry action (Order__c=10) to run before revenue action (Order__c=20).'
    );
  }

  @isTest
  static void updateCapturesOldAndNewRevenue() {
    // Transition assertions protect revenue logic against silent regressions.
    Account accountRecord = [
      SELECT
        Id,
        AnnualRevenue
      FROM Account
      WHERE External_ID__c = 'ACCT-TDD-SEED-UPDATE-001'
      LIMIT 1
    ];

    TriggerEventLogger.resetCapturedEvents();

    accountRecord.AnnualRevenue = 2400;
    update accountRecord;

    List<Map<String, Object>> events = TriggerEventLogger.capturedEvents;
    System.assertEquals(4, events.size(), 'Update should emit 4 Account events.');

    Map<String, Object> afterUpdateActionEvent = findEventByPrefix(events, 'REVLOG_AFTER_UPDATE_id=');
    String afterUpdateEventName = (String) afterUpdateActionEvent.get('eventName');

    System.assertEquals(
      1000,
      Decimal.valueOf(tokenValue(afterUpdateEventName, 'oldRevenue')),
      'Expected after update event to log old revenue.'
    );
    System.assertEquals(
      2400,
      Decimal.valueOf(tokenValue(afterUpdateEventName, 'newRevenue')),
      'Expected after update event to log new revenue.'
    );
  }

  @isTest
  static void bulkInsertRemainsBulkified() {
    // Bulk tests are your governor-limit safety net. The framework hands the
    // action one full chunk per context, so per-record events must scale while
    // per-context telemetry stays constant.
    TriggerEventLogger.resetCapturedEvents();

    insert new List<Account>{
      buildAccount('ACCT-TDD-BULK-001', 'BulkOne', 500),
      buildAccount('ACCT-TDD-BULK-002', 'BulkTwo', 600)
    };

    List<Map<String, Object>> events = TriggerEventLogger.capturedEvents;
    System.assertEquals(6, events.size(), 'Bulk insert of 2 records should emit 6 events total.');
    System.assertEquals(
      1,
      countEventsByName(events, 'BEFORE_INSERT'),
      'Expected one telemetry-action BEFORE_INSERT event.'
    );
    System.assertEquals(1, countEventsByName(events, 'AFTER_INSERT'), 'Expected one telemetry-action AFTER_INSERT event.');
    System.assertEquals(
      2,
      countEventsByPrefix(events, 'REVLOG_BEFORE_INSERT_id='),
      'Expected one before-action event per record.'
    );
    System.assertEquals(
      2,
      countEventsByPrefix(events, 'REVLOG_AFTER_INSERT_id='),
      'Expected one after-action event per record.'
    );
  }

  @isTest
  static void logCountersStayMonotonicWithinOneTransaction() {
    // CLRS-style invariant: counters should never decrease within one execution context.
    TriggerEventLogger.resetCapturedEvents();

    insert new List<Account>{
      buildAccount('ACCT-TDD-INVARIANT-001', 'InvariantOne', 700),
      buildAccount('ACCT-TDD-INVARIANT-002', 'InvariantTwo', 800)
    };

    List<Map<String, Object>> events = TriggerEventLogger.capturedEvents;
    System.assertEquals(6, events.size(), 'Expected 6 emitted events for 2 inserts.');

    Integer previousGlobalCalls = 0;
    Integer previousObjectCalls = 0;
    for (Map<String, Object> eventPayload : events) {
      Integer globalCalls = (Integer) eventPayload.get('logCalls');
      Integer objectCalls = (Integer) eventPayload.get('objectCalls');

      System.assertNotEquals(null, globalCalls, 'Expected logCalls counter in test payload.');
      System.assertNotEquals(null, objectCalls, 'Expected objectCalls counter in test payload.');
      System.assert(globalCalls >= previousGlobalCalls, 'Expected non-decreasing global counter.');
      System.assert(objectCalls >= previousObjectCalls, 'Expected non-decreasing per-object counter.');

      previousGlobalCalls = globalCalls;
      previousObjectCalls = objectCalls;
    }

    System.assertEquals(events.size(), previousGlobalCalls, 'Global counter should match number of emitted events.');
    System.assertEquals(
      events.size(),
      previousObjectCalls,
      'Per-object counter should match number of Account events.'
    );
  }

  @isTest
  static void afterInsertDoesNotMeanTransactionHasEnded() {
    // Run-once guard proof: telemetry-action events continue firing per
    // context, but the revenue action's static guards stop repeat emissions
    // within one execution context.
    TriggerEventLogger.resetCapturedEvents();

    Account accountRecord = buildAccount('ACCT-TDD-NOT-END-001', 'NotTheEnd', 1100);
    insert accountRecord;

    accountRecord.AnnualRevenue = 1900;
    update accountRecord;

    List<Map<String, Object>> events = TriggerEventLogger.capturedEvents;
    System.assertEquals(
      6,
      events.size(),
      'Insert + update in one method should emit 6 events with run-once action guards.'
    );
    System.assertEquals(
      0,
      countEventsByPrefix(events, 'REVLOG_BEFORE_UPDATE_id='),
      'Expected before-update action event to be skipped after first action invocation.'
    );
    System.assertEquals(
      0,
      countEventsByPrefix(events, 'REVLOG_AFTER_UPDATE_id='),
      'Expected after-update action event to be skipped after first action invocation.'
    );

    Integer afterInsertIndex = -1;
    Integer beforeUpdateIndex = -1;
    for (Integer eventIndex = 0; eventIndex < events.size(); eventIndex++) {
      String eventName = (String) events[eventIndex].get('eventName');
      if (afterInsertIndex == -1 && eventName == 'AFTER_INSERT') {
        afterInsertIndex = eventIndex;
      }
      if (beforeUpdateIndex == -1 && eventName == 'BEFORE_UPDATE') {
        beforeUpdateIndex = eventIndex;
      }
    }

    System.assert(afterInsertIndex >= 0, 'Expected an AFTER_INSERT event.');
    System.assert(
      beforeUpdateIndex > afterInsertIndex,
      'Expected more trigger activity after AFTER_INSERT in the same transaction.'
    );
  }

  @isTest
  static void directInvocationHonorsRunOnceGuard() {
    // Framework payoff #1: a trigger action is a plain Apex object. No DML,
    // no trigger context — construct it and call the interface method the way
    // MetadataTriggerHandler would.
    // Note: Trigger.operationType is null outside trigger context, so event
    // names degrade to 'REVLOG_null_...' here; assert on the stable tokens.
    // With phase gone from the name, before-events are identified by shape:
    // they never carry the _oldRevenue= token that after-events always do.
    TriggerEventLogger.resetCapturedEvents();

    List<Account> inMemoryAccounts = new List<Account>{
      buildAccount('ACCT-TDD-DIRECT-001', 'DirectOne', 300),
      buildAccount('ACCT-TDD-DIRECT-002', 'DirectTwo', 400)
    };

    TA_AccountRevenueLog revenueAction = new TA_AccountRevenueLog();
    revenueAction.beforeInsert(inMemoryAccounts);
    // Second call must hit the transaction-scoped guard and emit nothing.
    revenueAction.beforeInsert(inMemoryAccounts);

    List<Map<String, Object>> events = TriggerEventLogger.capturedEvents;
    System.assertEquals(2, events.size(), 'Run-once guard should limit direct calls to one event per record.');
    for (Map<String, Object> eventPayload : events) {
      String eventName = (String) eventPayload.get('eventName');
      System.assert(
        eventName.startsWith('REVLOG_'),
        'Expected only revenue-action events from direct beforeInsert calls.'
      );
      System.assert(
        !eventName.contains('_oldRevenue='),
        'Expected before-shaped events (no revenue tokens) from direct beforeInsert calls.'
      );
    }
    System.assert(
      ((String) events[0].get('eventName')).contains('_name=DirectOne'),
      'Expected first direct event to carry the first Account name.'
    );
    System.assert(
      ((String) events[1].get('eventName')).contains('_name=DirectTwo'),
      'Expected second direct event to carry the second Account name.'
    );
  }

  @isTest
  static void metadataBypassSkipsOnlyTheRevenueAction() {
    // Framework payoff #2: bypass is scoped to one action class, so telemetry
    // from TA_LogTriggerEvent keeps flowing while revenue breadcrumbs pause.
    // Solution Architect drill: this is the surgical off-switch you reach for
    // during data migrations instead of a blunt "disable all triggers" flag.
    MetadataTriggerHandler.bypass('TA_AccountRevenueLog');
    TriggerEventLogger.resetCapturedEvents();

    insert buildAccount('ACCT-TDD-BYPASS-001', 'BypassedInsert', 900);

    List<Map<String, Object>> events = TriggerEventLogger.capturedEvents;
    System.assertEquals(2, events.size(), 'Bypassed insert should emit telemetry-action events only.');
    System.assertEquals(1, countEventsByName(events, 'BEFORE_INSERT'), 'Expected telemetry BEFORE_INSERT to survive bypass.');
    System.assertEquals(1, countEventsByName(events, 'AFTER_INSERT'), 'Expected telemetry AFTER_INSERT to survive bypass.');
    System.assertEquals(
      0,
      countEventsByPrefix(events, 'REVLOG_BEFORE_INSERT_id='),
      'Expected no before-action events while bypassed.'
    );
    System.assertEquals(
      0,
      countEventsByPrefix(events, 'REVLOG_AFTER_INSERT_id='),
      'Expected no after-action events while bypassed.'
    );

    // Clearing the bypass restores the action. Its run-once guards are still
    // untripped — the action never executed above — so the next insert logs.
    MetadataTriggerHandler.clearBypass('TA_AccountRevenueLog');
    TriggerEventLogger.resetCapturedEvents();

    insert buildAccount('ACCT-TDD-BYPASS-002', 'RestoredInsert', 950);

    events = TriggerEventLogger.capturedEvents;
    System.assertEquals(4, events.size(), 'Post-bypass insert should emit all 4 Account events again.');
    System.assertEquals(
      1,
      countEventsByPrefix(events, 'REVLOG_BEFORE_INSERT_id='),
      'Expected the revenue action to resume after clearBypass.'
    );
  }
}
