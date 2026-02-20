public with sharing class TriggerEventLogger {
  private static final String LOG_PREFIX = 'TRIGGER_EVENT';

  @TestVisible
  private static List<Map<String, Object>> capturedEvents =
    new List<Map<String, Object>>();

  @TestVisible
  private static void resetCapturedEvents() {
    capturedEvents.clear();
  }

  public static void log(String objectName, String eventName) {
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
