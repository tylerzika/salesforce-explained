trigger ContactTrigger on Contact (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    TriggerEventLogger.log('Contact', String.valueOf(Trigger.operationType));
}
