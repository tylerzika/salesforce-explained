// Cleanup companion to scripts/apex/campaign-member.apex.
// Final sign-off: keep creation and teardown separate for safer reruns.
// Run this when you want to reset the sandbox records for a fresh insert path.

String accExID = 'ACCT-NIMBUS-ROASTERS-001';
String conExID = 'CONT-MAYA-PATEL-001';
String campExID = 'CAMP-Q2-WEBINAR-2026-001';
String camp2ExID = 'CAMP-Q3-ROUNDTABLE-2026-001';
String oppExID = 'OPP-ESPRESSO-SUBSCRIPTION-001';
String campMemExID = 'CM-WEBINAR-MAYA-PATEL-001';
String campMem2ExID = 'CM-ROUNDTABLE-MAYA-PATEL-001';

List<CampaignMember> campaignMembersToDelete = [
  SELECT Id
  FROM CampaignMember
  WHERE External_ID__c IN :new Set<String>{ campMemExID, campMem2ExID }
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
  WHERE External_ID__c IN :new Set<String>{ campExID, camp2ExID }
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

// Delete children first, then parents to avoid relationship constraints.
delete campaignMembersToDelete;
delete opportunityContactRolesToDelete;
delete opportunitiesToDelete;
delete campaignsToDelete;
delete contactsToDelete;
delete accountsToDelete;

System.debug(
  'Cleanup complete for Account, Contact, 2 Campaigns, Opportunity, 2 CampaignMembers, and OpportunityContactRole.'
);
