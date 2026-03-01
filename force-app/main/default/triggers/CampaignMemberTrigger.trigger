trigger CampaignMemberTrigger on CampaignMember(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  // SICP stream wink: two members in one upsert still flow through one transaction.
  // Role prep: member-volume events are where bulk limits usually show up first.
  TriggerEventLogger.log('CampaignMember', String.valueOf(Trigger.operationType));
}
