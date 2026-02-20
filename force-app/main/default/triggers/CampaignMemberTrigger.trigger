trigger CampaignMemberTrigger on CampaignMember(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  TriggerEventLogger.log(
    'CampaignMember',
    String.valueOf(Trigger.operationType)
  );
}
