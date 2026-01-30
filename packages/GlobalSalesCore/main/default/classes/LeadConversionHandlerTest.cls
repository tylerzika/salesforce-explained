/**
 * @description Test class for LeadConversionHandler
 * @author Salesforce Explained
 */
@isTest
private class LeadConversionHandlerTest {
    
    @testSetup
    static void setup() {
        // Create test leads
        List<Lead> testLeads = new List<Lead>();
        
        for (Integer i = 0; i < 5; i++) {
            Lead testLead = new Lead(
                FirstName = 'Test',
                LastName = 'Lead ' + i,
                Company = 'Test Company ' + i,
                Status = 'Open - Not Contacted',
                PreferredRegion__c = getRegionByIndex(i),
                RoutingPriority__c = 'Medium'
            );
            testLeads.add(testLead);
        }
        
        insert testLeads;
    }
    
    private static String getRegionByIndex(Integer index) {
        List<String> regions = new List<String>{'North America', 'EMEA', 'APAC', 'LATAM'};
        return regions[Math.mod(index, regions.size())];
    }
    
    @isTest
    static void testConvertLeadsWithRegion() {
        // Query test leads
        List<Lead> leads = [SELECT Id FROM Lead LIMIT 3];
        List<Id> leadIds = new List<Id>();
        
        for (Lead lead : leads) {
            leadIds.add(lead.Id);
        }
        
        Test.startTest();
        List<Id> opportunityIds = LeadConversionHandler.convertLeadsWithRegion(leadIds);
        Test.stopTest();
        
        // Verify conversions
        System.assertNotEquals(null, opportunityIds, 'Opportunity IDs should not be null');
        System.assertEquals(3, opportunityIds.size(), 'Should have converted 3 leads');
        
        // Verify opportunities have regions
        List<Opportunity> opportunities = [
            SELECT Id, SalesRegion__c 
            FROM Opportunity 
            WHERE Id IN :opportunityIds
        ];
        
        System.assertEquals(3, opportunities.size(), 'Should have created 3 opportunities');
        
        for (Opportunity opp : opportunities) {
            System.assertNotEquals(null, opp.SalesRegion__c, 'Opportunity should have a region');
        }
    }
    
    @isTest
    static void testConvertLeadsWithEmptyList() {
        Test.startTest();
        List<Id> opportunityIds = LeadConversionHandler.convertLeadsWithRegion(new List<Id>());
        Test.stopTest();
        
        System.assertNotEquals(null, opportunityIds, 'Should return empty list');
        System.assertEquals(0, opportunityIds.size(), 'Should be empty list');
    }
    
    @isTest
    static void testConvertLeadsWithNullList() {
        Test.startTest();
        List<Id> opportunityIds = LeadConversionHandler.convertLeadsWithRegion(null);
        Test.stopTest();
        
        System.assertNotEquals(null, opportunityIds, 'Should return empty list');
        System.assertEquals(0, opportunityIds.size(), 'Should be empty list');
    }
    
    @isTest
    static void testRouteLeadsToRegionalQueue() {
        List<Lead> leads = [SELECT Id FROM Lead LIMIT 5];
        List<Id> leadIds = new List<Id>();
        
        for (Lead lead : leads) {
            leadIds.add(lead.Id);
        }
        
        Test.startTest();
        LeadConversionHandler.routeLeadsToRegionalQueue(leadIds);
        Test.stopTest();
        
        // Verify leads still exist (routing doesn't delete them)
        List<Lead> routedLeads = [SELECT Id, PreferredRegion__c FROM Lead WHERE Id IN :leadIds];
        System.assertEquals(5, routedLeads.size(), 'All leads should still exist');
    }
    
    @isTest
    static void testRouteLeadsWithEmptyList() {
        Test.startTest();
        LeadConversionHandler.routeLeadsToRegionalQueue(new List<Id>());
        Test.stopTest();
        
        // Should not throw exception
        System.assert(true, 'Method should handle empty list gracefully');
    }
}
