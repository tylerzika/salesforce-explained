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
}
