trigger OpportunityTrigger on Opportunity(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  // One trigger per object, zero logic in the body: every behavior on Opportunity
  // is a Trigger_Action__mdt record executed by the base package's pipeline.
  new MetadataTriggerHandler().run();
}
