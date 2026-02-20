trigger OpportunityTrigger on Opportunity(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  TriggerEventLogger.log('Opportunity', String.valueOf(Trigger.operationType));
}
