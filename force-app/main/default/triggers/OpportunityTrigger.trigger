trigger OpportunityTrigger on Opportunity(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  // Opportunity path: data and control travel together through one execution frame.
  TriggerEventLogger.log('Opportunity', String.valueOf(Trigger.operationType));
}
