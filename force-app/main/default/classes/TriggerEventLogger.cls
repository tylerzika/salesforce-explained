public with sharing class TriggerEventLogger {
  private static final String LOG_PREFIX = 'TRIGGER_EVENT';
  private static final String LOG_COUNTER_LABEL = 'logCalls=';
  private static final String OBJECT_COUNTER_LABEL = 'objectCalls=';

  // Knuth lane marker: TAOCP Vol. 1 starts with program composition from
  // algorithms + data structures. Here, the structure is a class static counter.
  // SICP lane marker: this is state in one environment frame (execution context),
  // not global state across all time.
  // Transaction-scoped state: this value persists across all trigger/code-unit
  // invocations inside one Apex execution context, then resets next transaction.
  // Role prep (Platform Engineer): use transaction-local statics for recursion
  // guards and diagnostic counters, not as durable storage.
  // Role prep (Solution Architect): define a shared logging contract so every
  // domain trigger emits comparable telemetry.
  private static Integer logCalls = 0;
  // Change for Jim: reveal hidden cross-object rhythm inside one transaction.
  // Final sign-off note: validated from logs with stable signature counts
  // (Account=4, Campaign=4, Contact=2, Opportunity=2, CampaignMember=2).
  // CLRS Ch.2 lens: within one execution context, logCalls and per-object calls
  // should remain monotonic non-decreasing after each log() call.
  private static Map<String, Integer> logCallsByObject = new Map<String, Integer>();

  @TestVisible
  private static List<Map<String, Object>> capturedEvents = new List<Map<String, Object>>();

  @TestVisible
  private static void resetCapturedEvents() {
    capturedEvents.clear();
    logCalls = 0;
    logCallsByObject.clear();
  }

  public static void incrementLogCalls() {
    // Keep logger side effects lightweight: no SOQL, no DML, no callouts.
    logCalls++;
    System.debug(LoggingLevel.INFO, LOG_PREFIX + ' ' + LOG_COUNTER_LABEL + String.valueOf(logCalls));
  }

  private static Integer incrementLogCallsForObject(String objectName) {
    Integer objectCalls = logCallsByObject.containsKey(objectName) ? logCallsByObject.get(objectName) + 1 : 1;
    logCallsByObject.put(objectName, objectCalls);
    return objectCalls;
  }

  public static void log(String objectName, String eventName) {
    incrementLogCalls();
    Integer objectCalls = incrementLogCallsForObject(objectName);

    // Platform habit: turn runtime context into structured data first, then log.
    Map<String, Object> payload = TriggerContextInspector.snapshot(objectName, eventName);

    if (Test.isRunningTest()) {
      // Test seam: expose counter state so invariants can be asserted directly.
      payload.put('logCalls', logCalls);
      payload.put('objectCalls', objectCalls);
      capturedEvents.add(payload);
    }

    System.debug(
      LoggingLevel.INFO,
      LOG_PREFIX + ' object=' + objectName + ' ' + OBJECT_COUNTER_LABEL + String.valueOf(objectCalls)
    );
    System.debug(LoggingLevel.INFO, LOG_PREFIX + ' ' + JSON.serialize(payload));
  }
}
