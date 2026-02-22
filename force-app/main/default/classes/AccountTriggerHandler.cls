public with sharing class AccountTriggerHandler {
  // SICP hint: keep composition small and explicit; handlers build names via
  // tiny pure helpers while side effects stay in one place.
  // Role prep (Platform Engineer): preserve bulk safety by iterating Trigger.new
  // once and avoiding queries in per-record loops.
  // Role prep (Solution Architect): keep domain logic in handlers and keep
  // triggers as orchestration points only.
  public static void handleBeforeInsertUpdate(List<Account> newAccounts) {
    for (Account accountRecord : newAccounts) {
      TriggerEventLogger.log('Account', buildBeforeEventName(accountRecord));
    }
  }

  public static void handleAfterInsertUpdate(
    List<Account> newAccounts,
    Map<Id, Account> oldAccountMap
  ) {
    for (Account accountRecord : newAccounts) {
      String oldRevenue = (oldAccountMap != null &&
        oldAccountMap.containsKey(accountRecord.Id))
        ? String.valueOf(oldAccountMap.get(accountRecord.Id).AnnualRevenue)
        : 'null';
      TriggerEventLogger.log(
        'Account',
        buildAfterEventName(accountRecord, oldRevenue)
      );
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

  private static String buildAfterEventName(
    Account accountRecord,
    String oldRevenue
  ) {
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
