public with sharing class TA_LogTriggerEvent implements
  TriggerAction.BeforeInsert,
  TriggerAction.AfterInsert,
  TriggerAction.BeforeUpdate,
  TriggerAction.AfterUpdate,
  TriggerAction.BeforeDelete,
  TriggerAction.AfterDelete,
  TriggerAction.AfterUndelete {
  // One action, every object: the object name comes from the records instead
  // of a hardcoded string, so wiring a sixth object is pure metadata.
  // SICP lane marker: this is the dispatcher's behavior table externalized —
  // Trigger_Action__mdt rows are the table, this class is one shared entry.
  // Role prep (Platform Engineer): actions run inside trigger context, so
  // Trigger.operationType is still live here.
  // Role prep (Solution Architect): telemetry is now an opt-in subscription
  // per object/context, bypassable in metadata without touching code.

  public void beforeInsert(List<SObject> triggerNew) {
    log(triggerNew);
  }

  public void afterInsert(List<SObject> triggerNew) {
    log(triggerNew);
  }

  public void beforeUpdate(List<SObject> triggerNew, List<SObject> triggerOld) {
    log(triggerNew);
  }

  public void afterUpdate(List<SObject> triggerNew, List<SObject> triggerOld) {
    log(triggerNew);
  }

  public void beforeDelete(List<SObject> triggerOld) {
    log(triggerOld);
  }

  public void afterDelete(List<SObject> triggerOld) {
    log(triggerOld);
  }

  public void afterUndelete(List<SObject> triggerNew) {
    log(triggerNew);
  }

  private void log(List<SObject> records) {
    // Triggers never fire with an empty list, so records[0] is safe.
    TriggerEventLogger.log(
      String.valueOf(records[0].getSObjectType()),
      String.valueOf(Trigger.operationType)
    );
  }
}
