public with sharing class AccountTriggerHandler {
  public static void handleBeforeInsertUpdate(List<Account> newAccounts) {
    for (Account accountRecord : newAccounts) {
      TriggerEventLogger.log(
        'Account',
        'BEFORE_' +
          String.valueOf(Trigger.operationType) +
          '_id=' +
          String.valueOf(accountRecord.Id) +
          '_name=' +
          String.valueOf(accountRecord.Name)
      );
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
        'AFTER_' +
          String.valueOf(Trigger.operationType) +
          '_id=' +
          String.valueOf(accountRecord.Id) +
          '_name=' +
          String.valueOf(accountRecord.Name) +
          '_oldRevenue=' +
          oldRevenue +
          '_newRevenue=' +
          String.valueOf(accountRecord.AnnualRevenue)
      );
    }
  }
}
