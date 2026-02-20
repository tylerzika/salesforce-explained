trigger CampaignInfluenceTrigger on CampaignInfluence (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    TriggerEventLogger.log('CampaignInfluence', String.valueOf(Trigger.operationType));
}
