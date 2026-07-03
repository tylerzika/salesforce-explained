public with sharing class TA_AccountRevenueLog implements
  TriggerAction.BeforeInsert,
  TriggerAction.BeforeUpdate,
  TriggerAction.AfterInsert,
  TriggerAction.AfterUpdate {
  // Ported from AccountTriggerHandler onto the Trigger Actions Framework.
  // SICP hint: keep composition small and explicit; actions build names via
  // tiny pure helpers while side effects stay in one place.
  // Role prep (Platform Engineer): preserve bulk safety by iterating the
  // record list once and avoiding queries in per-record loops.
  // Role prep (Solution Architect): ordering vs. TA_LogTriggerEvent is now
  // declared in Trigger_Action__mdt.Order__c, not implied by trigger body.
  // Transaction-scoped run-once guards to prevent repeated execution in
  // recursive trigger scenarios. The framework alternative is
  // MetadataTriggerHandler.bypass('TA_AccountRevenueLog').
  private static Boolean hasRunBefore = false;
  private static Boolean hasRunAfter = false;

  public void beforeInsert(List<SObject> triggerNew) {
    handleBefore((List<Account>) triggerNew);
  }

  public void beforeUpdate(List<SObject> triggerNew, List<SObject> triggerOld) {
    handleBefore((List<Account>) triggerNew);
  }

  public void afterInsert(List<SObject> triggerNew) {
    handleAfter((List<Account>) triggerNew, null);
  }

  public void afterUpdate(List<SObject> triggerNew, List<SObject> triggerOld) {
    handleAfter((List<Account>) triggerNew, new Map<Id, Account>((List<Account>) triggerOld));
  }

  private void handleBefore(List<Account> newAccounts) {
    if (hasRunBefore) {
      return;
    }
    hasRunBefore = true;

    for (Account accountRecord : newAccounts) {
      TriggerEventLogger.log('Account', buildBeforeEventName(accountRecord));
    }
  }

  private void handleAfter(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {
    if (hasRunAfter) {
      return;
    }
    hasRunAfter = true;

    for (Account accountRecord : newAccounts) {
      String oldRevenue = (oldAccountMap != null && oldAccountMap.containsKey(accountRecord.Id))
        ? String.valueOf(oldAccountMap.get(accountRecord.Id).AnnualRevenue)
        : 'null';
      TriggerEventLogger.log('Account', buildAfterEventName(accountRecord, oldRevenue));
    }
  }

  // TAOCP easter egg: stable key order makes log scans feel like orderly runs.
  private static String buildBeforeEventName(Account accountRecord) {
    // Field-level breadcrumbs support quicker triage in production debugging.
    return 'BEFORE_' +
      String.valueOf(Trigger.operationType) +
      '_id=' +
      String.valueOf(accountRecord.Id) +
      '_name=' +
      String.valueOf(accountRecord.Name);
  }

  private static String buildAfterEventName(Account accountRecord, String oldRevenue) {
    // Architect mindset: include both previous and current values when the
    // business process depends on transitions, not just end state.
    return 'AFTER_' +
      String.valueOf(Trigger.operationType) +
      '_id=' +
      String.valueOf(accountRecord.Id) +
      '_name=' +
      String.valueOf(accountRecord.Name) +
      '_oldRevenue=' +
      oldRevenue +
      '_newRevenue=' +
      String.valueOf(accountRecord.AnnualRevenue);
  }
}
