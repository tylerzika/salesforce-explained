public with sharing class TriggerEventLogger {
    private static final String LOG_PREFIX = 'TRIGGER_EVENT';

    public static void log(String objectName, String eventName) {
        Map<String, Object> payload = TriggerContextInspector.snapshot(objectName, eventName);
        System.debug(LoggingLevel.INFO, LOG_PREFIX + ' ' + JSON.serialize(payload));
    }
}
