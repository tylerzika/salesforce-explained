/* Lead trigger event tour

Exercises every Lead trigger context wired up by the Trigger_Action.Lead_Log_*
CMDT records (all dispatching TA_LogTriggerEvent through the base package's
MetadataTriggerHandler pipeline):

- insert   -> BEFORE_INSERT, AFTER_INSERT
- update   -> BEFORE_UPDATE, AFTER_UPDATE
- delete   -> BEFORE_DELETE, AFTER_DELETE
- undelete -> AFTER_UNDELETE

All four DML statements share one execution context, so
TriggerEventLogger.logCalls climbs monotonically across all seven events —
same clapboard-counter behavior as scripts/apex/campaign-member.apex.

Run it and filter the debug log for the telemetry lines:

  sf apex run --file scripts/apex/lead-trigger-events.apex -o base \
    | grep -E 'TRIGGER_EVENT|LEAD-EVENT-TOUR'

Each context emits a `TRIGGER_EVENT {json}` line with the full
TriggerContextInspector snapshot (object, event, size, operationType, ...).

Rerun-safe: phase 0 purges any Lead left behind by a prior run. That purge
fires Lead delete events of its own — they land BEFORE the START marker, so
only count events between START and END.
*/
String marker = 'LEAD-EVENT-TOUR';
String tourCompany = 'Cirrus Coffee Supply';

// Phase 0: purge leftovers so reruns are deterministic. (Fires delete events
// pre-START; that's expected noise, not part of the tour.)
List<Lead> leftovers = [SELECT Id FROM Lead WHERE Company = :tourCompany];
if (!leftovers.isEmpty()) {
  delete leftovers;
  System.debug(
    marker +
      ' :: purged ' +
      leftovers.size() +
      ' leftover lead(s) from a prior run.'
  );
}

System.debug(marker + ' START :: expecting 7 TRIGGER_EVENT lines below.');

Lead tourLead = new Lead(
  FirstName = 'Rae',
  LastName = 'Delgado',
  Company = tourCompany,
  Title = 'Procurement Manager',
  OwnerId = UserInfo.getUserId()
);

System.debug(marker + ' [1/4] insert -> BEFORE_INSERT + AFTER_INSERT');
insert tourLead;

tourLead.Title = 'Director of Procurement';
System.debug(marker + ' [2/4] update -> BEFORE_UPDATE + AFTER_UPDATE');
update tourLead;

System.debug(marker + ' [3/4] delete -> BEFORE_DELETE + AFTER_DELETE');
delete tourLead;

System.debug(marker + ' [4/4] undelete -> AFTER_UNDELETE');
undelete tourLead;

System.debug(
  marker +
    ' END :: all 7 Lead contexts fired. Lead ' +
    tourLead.Id +
    ' left undeleted in the org; the next run purges it.'
);
