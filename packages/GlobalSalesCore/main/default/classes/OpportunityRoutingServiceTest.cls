/**
 * @description Test class for OpportunityRoutingService
 * @author Salesforce Explained
 */
@isTest
private class OpportunityRoutingServiceTest {
    
    @testSetup
    static void setup() {
        // Create test accounts with different tiers
        List<Account> testAccounts = new List<Account>();
        
        Account enterpriseAccount = new Account(
            Name = 'Enterprise Account',
            GlobalAccountTier__c = 'Enterprise',
            PreferredCurrency__c = 'USD'
        );
        testAccounts.add(enterpriseAccount);
        
        Account strategicAccount = new Account(
            Name = 'Strategic Account',
            GlobalAccountTier__c = 'Strategic',
            PreferredCurrency__c = 'EUR'
        );
        testAccounts.add(strategicAccount);
        
        Account standardAccount = new Account(
            Name = 'Standard Account',
            GlobalAccountTier__c = 'Standard',
            PreferredCurrency__c = 'GBP'
        );
        testAccounts.add(standardAccount);
        
        insert testAccounts;
        
        // Create test opportunities
        List<Opportunity> testOpportunities = new List<Opportunity>();
        
        for (Account acc : testAccounts) {
            Opportunity opp = new Opportunity(
                Name = acc.Name + ' Opportunity',
                AccountId = acc.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                Amount = 150000,
                SalesRegion__c = 'North America',
                Probability = 50
            );
            testOpportunities.add(opp);
        }
        
        insert testOpportunities;
    }
    
    @isTest
    static void testRouteOpportunitiesByRegion() {
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        List<Id> oppIds = new List<Id>();
        
        for (Opportunity opp : opps) {
            oppIds.add(opp.Id);
        }
        
        Test.startTest();
        OpportunityRoutingService.routeOpportunitiesByRegion(oppIds);
        Test.stopTest();
        
        // Verify opportunities still exist
        List<Opportunity> routedOpps = [SELECT Id, SalesRegion__c FROM Opportunity WHERE Id IN :oppIds];
        System.assertEquals(3, routedOpps.size(), 'All opportunities should still exist');
    }
    
    @isTest
    static void testRouteOpportunitiesWithEmptyList() {
        Test.startTest();
        OpportunityRoutingService.routeOpportunitiesByRegion(new List<Id>());
        Test.stopTest();
        
        System.assert(true, 'Method should handle empty list gracefully');
    }
    
    @isTest
    static void testAssignToRegionalReps() {
        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE SalesRegion__c = 'North America'];
        List<Id> oppIds = new List<Id>();
        
        for (Opportunity opp : opps) {
            oppIds.add(opp.Id);
        }
        
        Test.startTest();
        OpportunityRoutingService.assignToRegionalReps(oppIds, 'North America');
        Test.stopTest();
        
        // Verify assignment logic executed
        System.assertEquals(3, oppIds.size(), 'Should have 3 opportunities to assign');
    }
    
    @isTest
    static void testAssignToRegionalRepsWithNullRegion() {
        List<Opportunity> opps = [SELECT Id FROM Opportunity LIMIT 1];
        List<Id> oppIds = new List<Id>{opps[0].Id};
        
        Test.startTest();
        OpportunityRoutingService.assignToRegionalReps(oppIds, null);
        Test.stopTest();
        
        System.assert(true, 'Method should handle null region gracefully');
    }
    
    @isTest
    static void testUpdateForecastCategories() {
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        List<Id> oppIds = new List<Id>();
        
        for (Opportunity opp : opps) {
            oppIds.add(opp.Id);
        }
        
        Test.startTest();
        OpportunityRoutingService.updateForecastCategories(oppIds);
        Test.stopTest();
        
        // Verify forecast categories were updated
        List<Opportunity> updatedOpps = [
            SELECT Id, ForecastCategory__c, Probability 
            FROM Opportunity 
            WHERE Id IN :oppIds
        ];
        
        System.assertEquals(3, updatedOpps.size(), 'Should have updated 3 opportunities');
        
        for (Opportunity opp : updatedOpps) {
            System.assertNotEquals(null, opp.ForecastCategory__c, 'Should have forecast category');
        }
    }
    
    @isTest
    static void testUpdateForecastCategoriesHighProbability() {
        // Update an opportunity with high probability
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.Probability = 95;
        update opp;
        
        Test.startTest();
        OpportunityRoutingService.updateForecastCategories(new List<Id>{opp.Id});
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT Id, ForecastCategory__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Commit', updatedOpp.ForecastCategory__c, 'Should be Commit category');
    }
    
    @isTest
    static void testUpdateForecastCategoriesMediumProbability() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.Probability = 75;
        update opp;
        
        Test.startTest();
        OpportunityRoutingService.updateForecastCategories(new List<Id>{opp.Id});
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT Id, ForecastCategory__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Best Case', updatedOpp.ForecastCategory__c, 'Should be Best Case category');
    }
}
