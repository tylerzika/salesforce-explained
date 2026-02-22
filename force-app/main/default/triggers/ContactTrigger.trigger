trigger ContactTrigger on Contact(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  // Minimal trigger, maximum signal: TAOCP style "measure first, optimize later."
  TriggerEventLogger.log('Contact', String.valueOf(Trigger.operationType));
}
