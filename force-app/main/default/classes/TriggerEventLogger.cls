public with sharing class TriggerEventLogger {
  private static final String LOG_PREFIX = 'TRIGGER_EVENT';
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
      LOG_PREFIX + ' logCalls=' + String.valueOf(logCalls)
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
