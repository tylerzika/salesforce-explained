String accExID = 'ACCT-NIMBUS-ROASTERS-001';
String conExID = 'CONT-MAYA-PATEL-001';
String campExID = 'CAMP-Q2-WEBINAR-2026-001';
String oppExID = 'OPP-ESPRESSO-SUBSCRIPTION-001';
String campMemExID = 'CM-WEBINAR-MAYA-PATEL-001';

Account accountRecord = new Account(
    External_ID__c = accExID,
    Name = 'Nimbus Roasters'
);

Contact contactRecord = new Contact(
    External_ID__c = conExID,
    FirstName = 'Maya',
    LastName = 'Patel',
    Email = 'maya.patel@nimbusroasters.example',
    Title = 'Operations Director',
    Account = new Account(External_ID__c = accExID)
);

Campaign campaignRecord = new Campaign(
    External_ID__c = campExID,
    Name = 'Q2 2026 Wholesale Espresso Webinar',
    IsActive = true,
    Status = 'In Progress'
);

Opportunity opportunityRecord = new Opportunity(
    External_ID__c = oppExID,
    Name = 'Nimbus Roasters - Espresso Subscription Upgrade',
    StageName = 'Prospecting',
    CloseDate = Date.today().addDays(30),
    Amount = 18000,
    Account = new Account(External_ID__c = accExID)
);

upsert accountRecord External_ID__c;
upsert contactRecord External_ID__c;
upsert campaignRecord External_ID__c;
upsert opportunityRecord External_ID__c;

CampaignMember campaignMemberRecord = new CampaignMember(
    External_ID__c = campMemExID,
    Status = 'Responded',
    Campaign = new Campaign(External_ID__c = campExID),
    Contact = new Contact(External_ID__c = conExID)
);

upsert campaignMemberRecord External_ID__c;

System.debug('Upsert complete for Account, Contact, Campaign, Opportunity, and CampaignMember.');
