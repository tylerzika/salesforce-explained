/**
 * @description Handler class for lead conversion operations in global sales scenarios
 * @author Salesforce Explained
 */
public with sharing class LeadConversionHandler {
    
    /**
     * @description Converts leads with region-specific business logic
     * @param leadIds List of Lead IDs to convert
     * @return List of converted opportunity IDs
     */
    public static List<Id> convertLeadsWithRegion(List<Id> leadIds) {
        List<Id> opportunityIds = new List<Id>();
        
        if (leadIds == null || leadIds.isEmpty()) {
            return opportunityIds;
        }
        
        // Query leads with region information
        List<Lead> leadsToConvert = [
            SELECT Id, PreferredRegion__c, Company, LastName, Status
            FROM Lead
            WHERE Id IN :leadIds
            AND IsConverted = false
        ];
        
        for (Lead lead : leadsToConvert) {
            try {
                // Create lead conversion object
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(lead.Id);
                lc.setDoNotCreateOpportunity(false);
                lc.setConvertedStatus(getConvertedStatus());
                
                // Perform conversion
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                
                if (lcr.isSuccess()) {
                    opportunityIds.add(lcr.getOpportunityId());
                    
                    // Update opportunity with region
                    if (String.isNotBlank(lead.PreferredRegion__c)) {
                        updateOpportunityRegion(lcr.getOpportunityId(), lead.PreferredRegion__c);
                    }
                }
            } catch (Exception e) {
                System.debug('Error converting lead: ' + e.getMessage());
            }
        }
        
        return opportunityIds;
    }
    
    /**
     * @description Updates opportunity with regional information
     * @param opportunityId ID of the opportunity to update
     * @param region Region to assign
     */
    private static void updateOpportunityRegion(Id opportunityId, String region) {
        try {
            Opportunity opp = new Opportunity(
                Id = opportunityId,
                SalesRegion__c = region
            );
            update opp;
        } catch (Exception e) {
            System.debug('Error updating opportunity region: ' + e.getMessage());
        }
    }
    
    /**
     * @description Gets the converted status for leads
     * @return String representing converted status
     */
    private static String getConvertedStatus() {
        LeadStatus convertStatus = [
            SELECT MasterLabel 
            FROM LeadStatus 
            WHERE IsConverted = true 
            LIMIT 1
        ];
        return convertStatus.MasterLabel;
    }
    
    /**
     * @description Routes leads to regional queues based on preferred region
     * @param leadIds List of Lead IDs to route
     */
    public static void routeLeadsToRegionalQueue(List<Id> leadIds) {
        if (leadIds == null || leadIds.isEmpty()) {
            return;
        }
        
        List<Lead> leadsToRoute = [
            SELECT Id, PreferredRegion__c, RoutingPriority__c
            FROM Lead
            WHERE Id IN :leadIds
        ];
        
        List<Lead> leadsToUpdate = new List<Lead>();
        
        for (Lead lead : leadsToRoute) {
            if (String.isNotBlank(lead.PreferredRegion__c)) {
                // Logic to assign to regional queue would go here
                // This is a simplified example
                System.debug('Routing lead ' + lead.Id + ' to region: ' + lead.PreferredRegion__c);
            }
        }
    }
}
