trigger CampaignTrigger on Campaign(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  // Campaign attribution path marker: this event feeds the same transaction log stream.
  // Role prep: campaign-side telemetry helps attribution and pipeline explainability.
  TriggerEventLogger.log('Campaign', String.valueOf(Trigger.operationType));
}
