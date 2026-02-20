public with sharing class TriggerContextInspector {
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
