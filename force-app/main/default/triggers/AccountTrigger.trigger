trigger AccountTrigger on Account(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  // Dispatcher pattern (SICP 2.4.x vibes): decode context, route to behavior.
  // Role prep (Platform Engineer): one trigger per object avoids execution-order
  // ambiguity and simplifies incident debugging.
  // Role prep (Solution Architect): the trigger is an API boundary for all
  // automations touching Account; keep policy decisions in handlers/services.
  TriggerEventLogger.log('Account', String.valueOf(Trigger.operationType));

  if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
    AccountTriggerHandler.handleBeforeInsertUpdate(Trigger.new);
  }

  if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
    AccountTriggerHandler.handleAfterInsertUpdate(Trigger.new, Trigger.oldMap);
  }
}
