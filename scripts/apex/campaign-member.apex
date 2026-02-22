// Agentforce Sales core data slice:
// Account -> Contact -> Opportunity plus Campaign/CampaignMember attribution.
// This script intentionally creates data that exercises multiple trigger paths
// in one execution context (anonymous Apex transaction).
// TAOCP easter egg: one transaction, many operations, one evolving state table.
// SICP easter egg: the data model is the abstraction boundary; DML is the evaluator.

String accExID = 'ACCT-NIMBUS-ROASTERS-001';
String conExID = 'CONT-MAYA-PATEL-001';
String campExID = 'CAMP-Q2-WEBINAR-2026-001';
String camp2ExID = 'CAMP-Q3-ROUNDTABLE-2026-001';
String oppExID = 'OPP-ESPRESSO-SUBSCRIPTION-001';
String campMemExID = 'CM-WEBINAR-MAYA-PATEL-001';
String campMem2ExID = 'CM-ROUNDTABLE-MAYA-PATEL-001';

Account a = new Account(
    External_ID__c = accExID,
    Name = 'Nimbus Roasters'
);

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

// Each DML operation can fire before/after triggers.
// TriggerEventLogger.logCalls (a class static) keeps incrementing through all
// these trigger invocations because they run in the same transaction.
// Literal page nods (edition-sensitive): TAOCP Vol. 1 p.1, SICP p.1.
upsert a External_ID__c;
upsert c External_ID__c;
upsert camp1 External_ID__c;
upsert camp2 External_ID__c;
upsert opp External_ID__c;

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
upsert new List<CampaignMember>{campaignMemberRecord, campaignMemberRecord2} External_ID__c;

OpportunityContactRole oppConRole = new OpportunityContactRole(
    IsPrimary = true,
    Opportunity = new Opportunity(External_ID__c = oppExID),
    Contact = new Contact(External_ID__c = conExID)
);

upsert oppConRole;

System.debug(
    'Upsert complete for Account, Contact, 2 Campaigns, Opportunity, 2 CampaignMembers, and OpportunityContactRole.'
);

/*
// Cleanup block (commented out): deletes all data created by this script.
List<CampaignMember> campaignMembersToDelete = [
    SELECT Id
    FROM CampaignMember
    WHERE External_ID__c IN :new Set<String>{campMemExID, campMem2ExID}
];

List<OpportunityContactRole> opportunityContactRolesToDelete = [
    SELECT Id
    FROM OpportunityContactRole
    WHERE Opportunity.External_ID__c = :oppExID
      AND Contact.External_ID__c = :conExID
];

List<Opportunity> opportunitiesToDelete = [
    SELECT Id
    FROM Opportunity
    WHERE External_ID__c = :oppExID
];

List<Campaign> campaignsToDelete = [
    SELECT Id
    FROM Campaign
    WHERE External_ID__c IN :new Set<String>{campExID, camp2ExID}
];

List<Contact> contactsToDelete = [
    SELECT Id
    FROM Contact
    WHERE External_ID__c = :conExID
];

List<Account> accountsToDelete = [
    SELECT Id
    FROM Account
    WHERE External_ID__c = :accExID
];

delete campaignMembersToDelete;
delete opportunityContactRolesToDelete;
delete opportunitiesToDelete;
delete campaignsToDelete;
delete contactsToDelete;
delete accountsToDelete;
*/
