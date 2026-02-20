trigger AccountTrigger on Account (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    TriggerEventLogger.log('Account', String.valueOf(Trigger.operationType));

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        AccountTriggerHandler.handleBeforeInsertUpdate(Trigger.new);
    }

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        AccountTriggerHandler.handleAfterInsertUpdate(Trigger.new, Trigger.oldMap);
    }
}
