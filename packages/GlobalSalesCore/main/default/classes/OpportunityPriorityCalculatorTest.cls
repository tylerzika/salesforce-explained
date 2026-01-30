/**
 * @description Test class for OpportunityPriorityCalculator
 * @author Salesforce Explained
 */
@isTest
private class OpportunityPriorityCalculatorTest {
    
    @testSetup
    static void setup() {
        // Create test opportunities
        List<Opportunity> opps = new List<Opportunity>();
        
        // High priority - large amount
        opps.add(new Opportunity(
            Name = 'Large Deal',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 150000,
            SalesRegion__c = 'North America'
        ));
        
        // Medium priority - EMEA region
        opps.add(new Opportunity(
            Name = 'EMEA Deal',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 50000,
            SalesRegion__c = 'EMEA'
        ));
        
        // Low priority
        opps.add(new Opportunity(
            Name = 'Small Deal',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 10000,
            SalesRegion__c = 'North America'
        ));
        
        insert opps;
    }
    
    @isTest
    static void testHighPriorityCalculation() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Large Deal' LIMIT 1];
        
        OpportunityPriorityCalculator.Request req = new OpportunityPriorityCalculator.Request();
        req.opportunityId = opp.Id;
        
        Test.startTest();
        List<OpportunityPriorityCalculator.Result> results = 
            OpportunityPriorityCalculator.calculatePriority(new List<OpportunityPriorityCalculator.Request>{req});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals('High', results[0].priority, 'Large deal should be High priority');
    }
    
    @isTest
    static void testMediumPriorityCalculation() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'EMEA Deal' LIMIT 1];
        
        OpportunityPriorityCalculator.Request req = new OpportunityPriorityCalculator.Request();
        req.opportunityId = opp.Id;
        
        Test.startTest();
        List<OpportunityPriorityCalculator.Result> results = 
            OpportunityPriorityCalculator.calculatePriority(new List<OpportunityPriorityCalculator.Request>{req});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals('Medium', results[0].priority, 'EMEA deal should be Medium priority');
    }
    
    @isTest
    static void testLowPriorityCalculation() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Small Deal' LIMIT 1];
        
        OpportunityPriorityCalculator.Request req = new OpportunityPriorityCalculator.Request();
        req.opportunityId = opp.Id;
        
        Test.startTest();
        List<OpportunityPriorityCalculator.Result> results = 
            OpportunityPriorityCalculator.calculatePriority(new List<OpportunityPriorityCalculator.Request>{req});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals('Low', results[0].priority, 'Small deal should be Low priority');
    }
    
    @isTest
    static void testBulkCalculation() {
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        List<OpportunityPriorityCalculator.Request> requests = new List<OpportunityPriorityCalculator.Request>();
        
        for (Opportunity opp : opps) {
            OpportunityPriorityCalculator.Request req = new OpportunityPriorityCalculator.Request();
            req.opportunityId = opp.Id;
            requests.add(req);
        }
        
        Test.startTest();
        List<OpportunityPriorityCalculator.Result> results = 
            OpportunityPriorityCalculator.calculatePriority(requests);
        Test.stopTest();
        
        System.assertEquals(3, results.size(), 'Should return three results');
    }
}
