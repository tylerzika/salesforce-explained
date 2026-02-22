public with sharing class TriggerContextInspector {
  // SICP-flavored instrumentation: snapshot the "environment" (trigger context)
  // so behavior can be reasoned about from data, not only from control flow.
  // TAOCP-flavored note: this is our compact state table for one event.
  public static Map<String, Object> snapshot(
    String objectName,
    String eventName
  ) {
    Map<String, Object> payload = new Map<String, Object>();
    payload.put('objectName', objectName);
    payload.put('eventName', eventName);
    payload.put('isExecuting', Trigger.isExecuting);
    payload.put('isInsert', Trigger.isInsert);
    payload.put('isUpdate', Trigger.isUpdate);
    payload.put('isDelete', Trigger.isDelete);
    payload.put('isBefore', Trigger.isBefore);
    payload.put('isAfter', Trigger.isAfter);
    payload.put('isUndelete', Trigger.isUndelete);
    payload.put('newSize', Trigger.new == null ? 0 : Trigger.new.size());
    payload.put('oldSize', Trigger.old == null ? 0 : Trigger.old.size());
    return payload;
  }
}
