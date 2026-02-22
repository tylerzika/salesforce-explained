@isTest
private class AccountTriggerHandlerTest {
  // Role prep (Platform Engineer): tests should assert behavior contracts, not
  // implementation details, so refactors remain safe.
  // Role prep (Solution Architect): this suite is the executable specification
  // for Account trigger semantics and observability.
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
    // Insert path verifies both trigger-level and handler-level instrumentation.
    TriggerEventLogger.resetCapturedEvents();

    insert buildAccount('ACCT-TDD-INSERT-001', 'TddInsert', 1500);

    List<Map<String, Object>> events = TriggerEventLogger.capturedEvents;
    System.assertEquals(4, events.size(), 'Insert should emit 4 Account events.');

    Map<String, Object> beforeInsertTriggerEvent = findEventByName(events, 'BEFORE_INSERT');
    System.assertEquals(
      'Account',
      (String) beforeInsertTriggerEvent.get('objectName'),
      'Expected Account objectName in payload.'
    );
    System.assertEquals(
      true,
      (Boolean) beforeInsertTriggerEvent.get('isBefore'),
      'Expected BEFORE_INSERT event to be before-context.'
    );
    System.assertEquals(
      false,
      (Boolean) beforeInsertTriggerEvent.get('isAfter'),
      'Expected BEFORE_INSERT event to not be after-context.'
    );
    System.assertEquals(
      true,
      (Boolean) beforeInsertTriggerEvent.get('isInsert'),
      'Expected BEFORE_INSERT event to report insert context.'
    );
    System.assertEquals(1, (Integer) beforeInsertTriggerEvent.get('newSize'), 'Expected Trigger.new size of 1.');
    System.assertEquals(0, (Integer) beforeInsertTriggerEvent.get('oldSize'), 'Expected Trigger.old size of 0.');

    Map<String, Object> beforeHandlerEvent = findEventByPrefix(events, 'BEFORE_BEFORE_INSERT_id=');
    System.assert(
      ((String) beforeHandlerEvent.get('eventName')).contains('_name=TddInsert'),
      'Expected before-handler event to include the Account name.'
    );

    Map<String, Object> afterHandlerEvent = findEventByPrefix(events, 'AFTER_AFTER_INSERT_id=');
    String afterInsertEventName = (String) afterHandlerEvent.get('eventName');
    System.assert(
      afterInsertEventName.contains('_oldRevenue=null_'),
      'Expected after insert event to log null old revenue.'
    );
    System.assertEquals(
      1500,
      Decimal.valueOf(tokenValue(afterInsertEventName, 'newRevenue')),
      'Expected after insert event to log the new revenue.'
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

    Map<String, Object> afterUpdateHandlerEvent = findEventByPrefix(events, 'AFTER_AFTER_UPDATE_id=');
    String afterUpdateEventName = (String) afterUpdateHandlerEvent.get('eventName');

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
    // Bulk tests are your governor-limit safety net.
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
      'Expected one trigger-level BEFORE_INSERT event.'
    );
    System.assertEquals(1, countEventsByName(events, 'AFTER_INSERT'), 'Expected one trigger-level AFTER_INSERT event.');
    System.assertEquals(
      2,
      countEventsByPrefix(events, 'BEFORE_BEFORE_INSERT_id='),
      'Expected one before-handler event per record.'
    );
    System.assertEquals(
      2,
      countEventsByPrefix(events, 'AFTER_AFTER_INSERT_id='),
      'Expected one after-handler event per record.'
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
    // Run-once guard proof: trigger-level events continue, handler events do not repeat.
    TriggerEventLogger.resetCapturedEvents();

    Account accountRecord = buildAccount('ACCT-TDD-NOT-END-001', 'NotTheEnd', 1100);
    insert accountRecord;

    accountRecord.AnnualRevenue = 1900;
    update accountRecord;

    List<Map<String, Object>> events = TriggerEventLogger.capturedEvents;
    System.assertEquals(
      6,
      events.size(),
      'Insert + update in one method should emit 6 events with run-once handler guards.'
    );
    System.assertEquals(
      0,
      countEventsByPrefix(events, 'BEFORE_BEFORE_UPDATE_id='),
      'Expected before-update handler event to be skipped after first handler invocation.'
    );
    System.assertEquals(
      0,
      countEventsByPrefix(events, 'AFTER_AFTER_UPDATE_id='),
      'Expected after-update handler event to be skipped after first handler invocation.'
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
}
