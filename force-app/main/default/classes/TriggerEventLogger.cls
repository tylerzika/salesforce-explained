public with sharing class TriggerEventLogger {
  private static final String LOG_PREFIX = 'TRIGGER_EVENT';
  private static final String LOG_COUNTER_LABEL = 'logCalls=';

  // Knuth lane marker: TAOCP Vol. 1 starts with program composition from
  // algorithms + data structures. Here, the structure is a class static counter.
  // SICP lane marker: this is state in one environment frame (execution context),
  // not global state across all time.
  // Transaction-scoped state: this value persists across all trigger/code-unit
  // invocations inside one Apex execution context, then resets next transaction.
  private static Integer logCalls = 0;

  @TestVisible
  private static List<Map<String, Object>> capturedEvents = new List<Map<String, Object>>();

  @TestVisible
  private static void resetCapturedEvents() {
    capturedEvents.clear();
    logCalls = 0;
  }

  public static void incrementLogCalls() {
    logCalls++;
    System.debug(
      LoggingLevel.INFO,
      LOG_PREFIX + ' ' + LOG_COUNTER_LABEL + String.valueOf(logCalls)
    );
  }

  public static void log(String objectName, String eventName) {
    incrementLogCalls();

    Map<String, Object> payload = TriggerContextInspector.snapshot(
      objectName,
      eventName
    );

    if (Test.isRunningTest()) {
      capturedEvents.add(payload);
    }

    System.debug(LoggingLevel.INFO, LOG_PREFIX + ' ' + JSON.serialize(payload));
  }
}
