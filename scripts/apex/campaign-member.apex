// Agentforce Sales core data slice:
// Account -> Contact -> Opportunity plus Campaign/CampaignMember attribution.
// This script intentionally creates data that exercises multiple trigger paths
// in one execution context (anonymous Apex transaction).
// TAOCP easter egg: one transaction, many operations, one evolving state table.
// SICP easter egg: the data model is the abstraction boundary; DML is the evaluator.
// Role prep (Platform Engineer now): treat this file as an idempotent seed
// script for repeatable debugging and demo scenarios.
// Role prep (Solution Architect in 2 years): this object graph models core
// lead-to-revenue entities and their attribution links.
// Final sign-off: this file is now create/upsert only.
// Teardown lives in scripts/apex/campaign-member-cleanup.apex.

String accExID = 'ACCT-NIMBUS-ROASTERS-001';
String conExID = 'CONT-MAYA-PATEL-001';
String campExID = 'CAMP-Q2-WEBINAR-2026-001';
String camp2ExID = 'CAMP-Q3-ROUNDTABLE-2026-001';
String oppExID = 'OPP-ESPRESSO-SUBSCRIPTION-001';
String campMemExID = 'CM-WEBINAR-MAYA-PATEL-001';
String campMem2ExID = 'CM-ROUNDTABLE-MAYA-PATEL-001';

String checkpointLabel;
Integer dmlStatementsUsed;
Integer dmlStatementsLimit;
Integer dmlStatementsPct;
String dmlStatementsState;
Integer dmlRowsUsed;
Integer dmlRowsLimit;
Integer dmlRowsPct;
String dmlRowsState;
Integer soqlQueriesUsed;
Integer soqlQueriesLimit;
Integer soqlQueriesPct;
String soqlQueriesState;
Integer soqlRowsUsed;
Integer soqlRowsLimit;
Integer soqlRowsPct;
String soqlRowsState;
Integer cpuTimeUsed;
Integer cpuTimeLimit;
Integer cpuTimePct;
String cpuTimeState;
Integer heapBytesUsed;
Integer heapBytesLimit;
Integer heapBytesPct;
String heapBytesState;
Boolean hasCaution;
Boolean hasCritical;

Account a = new Account(External_ID__c = accExID, Name = 'Nimbus Roasters');

Contact c = new Contact(
  External_ID__c = conExID,
  FirstName = 'Maya',
  LastName = 'Patel',
  Email = 'maya.patel@nimbusroasters.example',
  Title = 'Operations Director',
  Account = new Account(External_ID__c = accExID)
);

Campaign camp1 = new Campaign(
  External_ID__c = campExID,
  Name = 'Q2 2026 Wholesale Espresso Webinar',
  IsActive = true,
  Status = 'In Progress'
);

Campaign camp2 = new Campaign(
  External_ID__c = camp2ExID,
  Name = 'Q3 2026 Supply Chain Roundtable',
  IsActive = true,
  Status = 'In Progress'
);

Opportunity opp = new Opportunity(
  External_ID__c = oppExID,
  Name = 'Espresso Subscription Upgrade',
  StageName = 'Prospecting',
  CloseDate = Date.today().addDays(30),
  Amount = 18000,
  Account = new Account(External_ID__c = accExID)
);

checkpointLabel = 'BOOT';
dmlStatementsUsed = Limits.getDmlStatements();
dmlStatementsLimit = Limits.getLimitDmlStatements();
dmlStatementsPct = dmlStatementsLimit == 0
  ? 0
  : (dmlStatementsUsed * 100) / dmlStatementsLimit;
dmlStatementsState = dmlStatementsPct >= 90
  ? 'RED-LINE'
  : dmlStatementsPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
dmlRowsUsed = Limits.getDmlRows();
dmlRowsLimit = Limits.getLimitDmlRows();
dmlRowsPct = dmlRowsLimit == 0 ? 0 : (dmlRowsUsed * 100) / dmlRowsLimit;
dmlRowsState = dmlRowsPct >= 90
  ? 'RED-LINE'
  : dmlRowsPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
soqlQueriesUsed = Limits.getQueries();
soqlQueriesLimit = Limits.getLimitQueries();
soqlQueriesPct = soqlQueriesLimit == 0
  ? 0
  : (soqlQueriesUsed * 100) / soqlQueriesLimit;
soqlQueriesState = soqlQueriesPct >= 90
  ? 'RED-LINE'
  : soqlQueriesPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
soqlRowsUsed = Limits.getQueryRows();
soqlRowsLimit = Limits.getLimitQueryRows();
soqlRowsPct = soqlRowsLimit == 0 ? 0 : (soqlRowsUsed * 100) / soqlRowsLimit;
soqlRowsState = soqlRowsPct >= 90
  ? 'RED-LINE'
  : soqlRowsPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
cpuTimeUsed = Limits.getCpuTime();
cpuTimeLimit = Limits.getLimitCpuTime();
cpuTimePct = cpuTimeLimit == 0 ? 0 : (cpuTimeUsed * 100) / cpuTimeLimit;
cpuTimeState = cpuTimePct >= 90
  ? 'RED-LINE'
  : cpuTimePct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
heapBytesUsed = Limits.getHeapSize();
heapBytesLimit = Limits.getLimitHeapSize();
heapBytesPct = heapBytesLimit == 0 ? 0 : (heapBytesUsed * 100) / heapBytesLimit;
heapBytesState = heapBytesPct >= 90
  ? 'RED-LINE'
  : heapBytesPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
hasCaution = dmlStatementsPct >= 70 ||
  dmlRowsPct >= 70 ||
  soqlQueriesPct >= 70 ||
  soqlRowsPct >= 70 ||
  cpuTimePct >= 70 ||
  heapBytesPct >= 70;
hasCritical = dmlStatementsPct >= 90 ||
  dmlRowsPct >= 90 ||
  soqlQueriesPct >= 90 ||
  soqlRowsPct >= 90 ||
  cpuTimePct >= 90 ||
  heapBytesPct >= 90;
System.debug(
  'CRANKY-LIMIT-BOT [' +
    checkpointLabel +
    '] :: DML statements ' +
    dmlStatementsUsed +
    '/' +
    dmlStatementsLimit +
    ' (' +
    dmlStatementsPct +
    '%, ' +
    dmlStatementsState +
    ') | DML rows ' +
    dmlRowsUsed +
    '/' +
    dmlRowsLimit +
    ' (' +
    dmlRowsPct +
    '%, ' +
    dmlRowsState +
    ') | SOQL queries ' +
    soqlQueriesUsed +
    '/' +
    soqlQueriesLimit +
    ' (' +
    soqlQueriesPct +
    '%, ' +
    soqlQueriesState +
    ') | Query rows ' +
    soqlRowsUsed +
    '/' +
    soqlRowsLimit +
    ' (' +
    soqlRowsPct +
    '%, ' +
    soqlRowsState +
    ') | CPU ' +
    cpuTimeUsed +
    '/' +
    cpuTimeLimit +
    ' ms (' +
    cpuTimePct +
    '%, ' +
    cpuTimeState +
    ') | Heap ' +
    heapBytesUsed +
    '/' +
    heapBytesLimit +
    ' bytes (' +
    heapBytesPct +
    '%, ' +
    heapBytesState +
    ').'
);
if (hasCritical) {
  System.debug(
    'CRANKY-LIMIT-BOT ALERT [' +
      checkpointLabel +
      '] :: Critical threshold breached. Stop feeding this transaction extra automation.'
  );
} else if (hasCaution) {
  System.debug(
    'CRANKY-LIMIT-BOT WARNING [' +
      checkpointLabel +
      '] :: Usage above 70%. Salesforce governor limits are hard stops, not motivational posters.'
  );
} else {
  System.debug(
    'CRANKY-LIMIT-BOT STATUS [' +
      checkpointLabel +
      '] :: Resource draw is acceptable, reluctantly.'
  );
}

// Each DML operation can fire before/after triggers.
// TriggerEventLogger.logCalls (a class static) keeps incrementing through all
// these trigger invocations because they run in the same transaction.
// Literal page nods (edition-sensitive): TAOCP Vol. 1 p.1, SICP p.1.
// Integration mindset: External_ID__c-based upserts make reruns deterministic.
upsert a External_ID__c;
upsert c External_ID__c;
upsert camp1 External_ID__c;
upsert camp2 External_ID__c;
upsert opp External_ID__c;

checkpointLabel = 'POST-CORE-DML';
dmlStatementsUsed = Limits.getDmlStatements();
dmlStatementsLimit = Limits.getLimitDmlStatements();
dmlStatementsPct = dmlStatementsLimit == 0
  ? 0
  : (dmlStatementsUsed * 100) / dmlStatementsLimit;
dmlStatementsState = dmlStatementsPct >= 90
  ? 'RED-LINE'
  : dmlStatementsPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
dmlRowsUsed = Limits.getDmlRows();
dmlRowsLimit = Limits.getLimitDmlRows();
dmlRowsPct = dmlRowsLimit == 0 ? 0 : (dmlRowsUsed * 100) / dmlRowsLimit;
dmlRowsState = dmlRowsPct >= 90
  ? 'RED-LINE'
  : dmlRowsPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
soqlQueriesUsed = Limits.getQueries();
soqlQueriesLimit = Limits.getLimitQueries();
soqlQueriesPct = soqlQueriesLimit == 0
  ? 0
  : (soqlQueriesUsed * 100) / soqlQueriesLimit;
soqlQueriesState = soqlQueriesPct >= 90
  ? 'RED-LINE'
  : soqlQueriesPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
soqlRowsUsed = Limits.getQueryRows();
soqlRowsLimit = Limits.getLimitQueryRows();
soqlRowsPct = soqlRowsLimit == 0 ? 0 : (soqlRowsUsed * 100) / soqlRowsLimit;
soqlRowsState = soqlRowsPct >= 90
  ? 'RED-LINE'
  : soqlRowsPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
cpuTimeUsed = Limits.getCpuTime();
cpuTimeLimit = Limits.getLimitCpuTime();
cpuTimePct = cpuTimeLimit == 0 ? 0 : (cpuTimeUsed * 100) / cpuTimeLimit;
cpuTimeState = cpuTimePct >= 90
  ? 'RED-LINE'
  : cpuTimePct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
heapBytesUsed = Limits.getHeapSize();
heapBytesLimit = Limits.getLimitHeapSize();
heapBytesPct = heapBytesLimit == 0 ? 0 : (heapBytesUsed * 100) / heapBytesLimit;
heapBytesState = heapBytesPct >= 90
  ? 'RED-LINE'
  : heapBytesPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
hasCaution = dmlStatementsPct >= 70 ||
  dmlRowsPct >= 70 ||
  soqlQueriesPct >= 70 ||
  soqlRowsPct >= 70 ||
  cpuTimePct >= 70 ||
  heapBytesPct >= 70;
hasCritical = dmlStatementsPct >= 90 ||
  dmlRowsPct >= 90 ||
  soqlQueriesPct >= 90 ||
  soqlRowsPct >= 90 ||
  cpuTimePct >= 90 ||
  heapBytesPct >= 90;
System.debug(
  'CRANKY-LIMIT-BOT [' +
    checkpointLabel +
    '] :: DML statements ' +
    dmlStatementsUsed +
    '/' +
    dmlStatementsLimit +
    ' (' +
    dmlStatementsPct +
    '%, ' +
    dmlStatementsState +
    ') | DML rows ' +
    dmlRowsUsed +
    '/' +
    dmlRowsLimit +
    ' (' +
    dmlRowsPct +
    '%, ' +
    dmlRowsState +
    ') | SOQL queries ' +
    soqlQueriesUsed +
    '/' +
    soqlQueriesLimit +
    ' (' +
    soqlQueriesPct +
    '%, ' +
    soqlQueriesState +
    ') | Query rows ' +
    soqlRowsUsed +
    '/' +
    soqlRowsLimit +
    ' (' +
    soqlRowsPct +
    '%, ' +
    soqlRowsState +
    ') | CPU ' +
    cpuTimeUsed +
    '/' +
    cpuTimeLimit +
    ' ms (' +
    cpuTimePct +
    '%, ' +
    cpuTimeState +
    ') | Heap ' +
    heapBytesUsed +
    '/' +
    heapBytesLimit +
    ' bytes (' +
    heapBytesPct +
    '%, ' +
    heapBytesState +
    ').'
);
if (hasCritical) {
  System.debug(
    'CRANKY-LIMIT-BOT ALERT [' +
      checkpointLabel +
      '] :: Critical threshold breached. Stop feeding this transaction extra automation.'
  );
} else if (hasCaution) {
  System.debug(
    'CRANKY-LIMIT-BOT WARNING [' +
      checkpointLabel +
      '] :: Usage above 70%. Salesforce governor limits are hard stops, not motivational posters.'
  );
} else {
  System.debug(
    'CRANKY-LIMIT-BOT STATUS [' +
      checkpointLabel +
      '] :: Resource draw is acceptable, reluctantly.'
  );
}

CampaignMember campaignMemberRecord = new CampaignMember(
  External_ID__c = campMemExID,
  Status = 'Responded',
  Campaign = new Campaign(External_ID__c = campExID),
  Contact = new Contact(External_ID__c = conExID)
);

CampaignMember campaignMemberRecord2 = new CampaignMember(
  External_ID__c = campMem2ExID,
  Status = 'Responded',
  Campaign = new Campaign(External_ID__c = camp2ExID),
  Contact = new Contact(External_ID__c = conExID)
);

// Bulk upsert of two members, so Trigger.new size is 2 in CampaignMember trigger.
// SICP 3.x wink: sequence matters because side effects (trigger logs) are observed.
upsert new List<CampaignMember>{ campaignMemberRecord, campaignMemberRecord2 }
  External_ID__c;

checkpointLabel = 'POST-CAMPAIGN-MEMBERS';
dmlStatementsUsed = Limits.getDmlStatements();
dmlStatementsLimit = Limits.getLimitDmlStatements();
dmlStatementsPct = dmlStatementsLimit == 0
  ? 0
  : (dmlStatementsUsed * 100) / dmlStatementsLimit;
dmlStatementsState = dmlStatementsPct >= 90
  ? 'RED-LINE'
  : dmlStatementsPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
dmlRowsUsed = Limits.getDmlRows();
dmlRowsLimit = Limits.getLimitDmlRows();
dmlRowsPct = dmlRowsLimit == 0 ? 0 : (dmlRowsUsed * 100) / dmlRowsLimit;
dmlRowsState = dmlRowsPct >= 90
  ? 'RED-LINE'
  : dmlRowsPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
soqlQueriesUsed = Limits.getQueries();
soqlQueriesLimit = Limits.getLimitQueries();
soqlQueriesPct = soqlQueriesLimit == 0
  ? 0
  : (soqlQueriesUsed * 100) / soqlQueriesLimit;
soqlQueriesState = soqlQueriesPct >= 90
  ? 'RED-LINE'
  : soqlQueriesPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
soqlRowsUsed = Limits.getQueryRows();
soqlRowsLimit = Limits.getLimitQueryRows();
soqlRowsPct = soqlRowsLimit == 0 ? 0 : (soqlRowsUsed * 100) / soqlRowsLimit;
soqlRowsState = soqlRowsPct >= 90
  ? 'RED-LINE'
  : soqlRowsPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
cpuTimeUsed = Limits.getCpuTime();
cpuTimeLimit = Limits.getLimitCpuTime();
cpuTimePct = cpuTimeLimit == 0 ? 0 : (cpuTimeUsed * 100) / cpuTimeLimit;
cpuTimeState = cpuTimePct >= 90
  ? 'RED-LINE'
  : cpuTimePct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
heapBytesUsed = Limits.getHeapSize();
heapBytesLimit = Limits.getLimitHeapSize();
heapBytesPct = heapBytesLimit == 0 ? 0 : (heapBytesUsed * 100) / heapBytesLimit;
heapBytesState = heapBytesPct >= 90
  ? 'RED-LINE'
  : heapBytesPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
hasCaution = dmlStatementsPct >= 70 ||
  dmlRowsPct >= 70 ||
  soqlQueriesPct >= 70 ||
  soqlRowsPct >= 70 ||
  cpuTimePct >= 70 ||
  heapBytesPct >= 70;
hasCritical = dmlStatementsPct >= 90 ||
  dmlRowsPct >= 90 ||
  soqlQueriesPct >= 90 ||
  soqlRowsPct >= 90 ||
  cpuTimePct >= 90 ||
  heapBytesPct >= 90;
System.debug(
  'CRANKY-LIMIT-BOT [' +
    checkpointLabel +
    '] :: DML statements ' +
    dmlStatementsUsed +
    '/' +
    dmlStatementsLimit +
    ' (' +
    dmlStatementsPct +
    '%, ' +
    dmlStatementsState +
    ') | DML rows ' +
    dmlRowsUsed +
    '/' +
    dmlRowsLimit +
    ' (' +
    dmlRowsPct +
    '%, ' +
    dmlRowsState +
    ') | SOQL queries ' +
    soqlQueriesUsed +
    '/' +
    soqlQueriesLimit +
    ' (' +
    soqlQueriesPct +
    '%, ' +
    soqlQueriesState +
    ') | Query rows ' +
    soqlRowsUsed +
    '/' +
    soqlRowsLimit +
    ' (' +
    soqlRowsPct +
    '%, ' +
    soqlRowsState +
    ') | CPU ' +
    cpuTimeUsed +
    '/' +
    cpuTimeLimit +
    ' ms (' +
    cpuTimePct +
    '%, ' +
    cpuTimeState +
    ') | Heap ' +
    heapBytesUsed +
    '/' +
    heapBytesLimit +
    ' bytes (' +
    heapBytesPct +
    '%, ' +
    heapBytesState +
    ').'
);
if (hasCritical) {
  System.debug(
    'CRANKY-LIMIT-BOT ALERT [' +
      checkpointLabel +
      '] :: Critical threshold breached. Stop feeding this transaction extra automation.'
  );
} else if (hasCaution) {
  System.debug(
    'CRANKY-LIMIT-BOT WARNING [' +
      checkpointLabel +
      '] :: Usage above 70%. Salesforce governor limits are hard stops, not motivational posters.'
  );
} else {
  System.debug(
    'CRANKY-LIMIT-BOT STATUS [' +
      checkpointLabel +
      '] :: Resource draw is acceptable, reluctantly.'
  );
}

OpportunityContactRole oppConRole = new OpportunityContactRole(
  IsPrimary = true,
  Opportunity = new Opportunity(External_ID__c = oppExID),
  Contact = new Contact(External_ID__c = conExID)
);

upsert oppConRole;

checkpointLabel = 'FINAL';
dmlStatementsUsed = Limits.getDmlStatements();
dmlStatementsLimit = Limits.getLimitDmlStatements();
dmlStatementsPct = dmlStatementsLimit == 0
  ? 0
  : (dmlStatementsUsed * 100) / dmlStatementsLimit;
dmlStatementsState = dmlStatementsPct >= 90
  ? 'RED-LINE'
  : dmlStatementsPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
dmlRowsUsed = Limits.getDmlRows();
dmlRowsLimit = Limits.getLimitDmlRows();
dmlRowsPct = dmlRowsLimit == 0 ? 0 : (dmlRowsUsed * 100) / dmlRowsLimit;
dmlRowsState = dmlRowsPct >= 90
  ? 'RED-LINE'
  : dmlRowsPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
soqlQueriesUsed = Limits.getQueries();
soqlQueriesLimit = Limits.getLimitQueries();
soqlQueriesPct = soqlQueriesLimit == 0
  ? 0
  : (soqlQueriesUsed * 100) / soqlQueriesLimit;
soqlQueriesState = soqlQueriesPct >= 90
  ? 'RED-LINE'
  : soqlQueriesPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
soqlRowsUsed = Limits.getQueryRows();
soqlRowsLimit = Limits.getLimitQueryRows();
soqlRowsPct = soqlRowsLimit == 0 ? 0 : (soqlRowsUsed * 100) / soqlRowsLimit;
soqlRowsState = soqlRowsPct >= 90
  ? 'RED-LINE'
  : soqlRowsPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
cpuTimeUsed = Limits.getCpuTime();
cpuTimeLimit = Limits.getLimitCpuTime();
cpuTimePct = cpuTimeLimit == 0 ? 0 : (cpuTimeUsed * 100) / cpuTimeLimit;
cpuTimeState = cpuTimePct >= 90
  ? 'RED-LINE'
  : cpuTimePct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
heapBytesUsed = Limits.getHeapSize();
heapBytesLimit = Limits.getLimitHeapSize();
heapBytesPct = heapBytesLimit == 0 ? 0 : (heapBytesUsed * 100) / heapBytesLimit;
heapBytesState = heapBytesPct >= 90
  ? 'RED-LINE'
  : heapBytesPct >= 70 ? 'YELLOW-LINE' : 'GREEN-LINE';
hasCaution = dmlStatementsPct >= 70 ||
  dmlRowsPct >= 70 ||
  soqlQueriesPct >= 70 ||
  soqlRowsPct >= 70 ||
  cpuTimePct >= 70 ||
  heapBytesPct >= 70;
hasCritical = dmlStatementsPct >= 90 ||
  dmlRowsPct >= 90 ||
  soqlQueriesPct >= 90 ||
  soqlRowsPct >= 90 ||
  cpuTimePct >= 90 ||
  heapBytesPct >= 90;
System.debug(
  'CRANKY-LIMIT-BOT [' +
    checkpointLabel +
    '] :: DML statements ' +
    dmlStatementsUsed +
    '/' +
    dmlStatementsLimit +
    ' (' +
    dmlStatementsPct +
    '%, ' +
    dmlStatementsState +
    ') | DML rows ' +
    dmlRowsUsed +
    '/' +
    dmlRowsLimit +
    ' (' +
    dmlRowsPct +
    '%, ' +
    dmlRowsState +
    ') | SOQL queries ' +
    soqlQueriesUsed +
    '/' +
    soqlQueriesLimit +
    ' (' +
    soqlQueriesPct +
    '%, ' +
    soqlQueriesState +
    ') | Query rows ' +
    soqlRowsUsed +
    '/' +
    soqlRowsLimit +
    ' (' +
    soqlRowsPct +
    '%, ' +
    soqlRowsState +
    ') | CPU ' +
    cpuTimeUsed +
    '/' +
    cpuTimeLimit +
    ' ms (' +
    cpuTimePct +
    '%, ' +
    cpuTimeState +
    ') | Heap ' +
    heapBytesUsed +
    '/' +
    heapBytesLimit +
    ' bytes (' +
    heapBytesPct +
    '%, ' +
    heapBytesState +
    ').'
);
if (hasCritical) {
  System.debug(
    'CRANKY-LIMIT-BOT ALERT [' +
      checkpointLabel +
      '] :: Critical threshold breached. Stop feeding this transaction extra automation.'
  );
} else if (hasCaution) {
  System.debug(
    'CRANKY-LIMIT-BOT WARNING [' +
      checkpointLabel +
      '] :: Usage above 70%. Salesforce governor limits are hard stops, not motivational posters.'
  );
} else {
  System.debug(
    'CRANKY-LIMIT-BOT STATUS [' +
      checkpointLabel +
      '] :: Resource draw is acceptable, reluctantly.'
  );
}
System.debug(
  'CRANKY-LIMIT-BOT COMPLETE :: Upsert complete for Account, Contact, 2 Campaigns, Opportunity, 2 CampaignMembers, and OpportunityContactRole. Platform limits remain under surveillance.'
);
