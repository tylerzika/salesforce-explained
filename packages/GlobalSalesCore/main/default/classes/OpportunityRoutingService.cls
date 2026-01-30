/**
 * @description Service class for opportunity routing based on region and tier
 * @author Salesforce Explained
 */
public with sharing class OpportunityRoutingService {
    
    /**
     * @description Routes opportunities to regional sales teams based on criteria
     * @param opportunityIds List of Opportunity IDs to route
     */
    public static void routeOpportunitiesByRegion(List<Id> opportunityIds) {
        if (opportunityIds == null || opportunityIds.isEmpty()) {
            return;
        }
        
        List<Opportunity> opportunities = [
            SELECT Id, SalesRegion__c, Amount, AccountId, Account.GlobalAccountTier__c
            FROM Opportunity
            WHERE Id IN :opportunityIds
        ];
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        for (Opportunity opp : opportunities) {
            if (String.isNotBlank(opp.SalesRegion__c)) {
                // Determine routing priority based on region and account tier
                String priority = determineRoutingPriority(
                    opp.SalesRegion__c, 
                    opp.Account?.GlobalAccountTier__c,
                    opp.Amount
                );
                
                System.debug('Routing opportunity ' + opp.Id + ' to region: ' + 
                           opp.SalesRegion__c + ' with priority: ' + priority);
            }
        }
    }
    
    /**
     * @description Determines routing priority based on multiple factors
     * @param region Sales region
     * @param accountTier Account tier
     * @param amount Opportunity amount
     * @return String representing priority level
     */
    private static String determineRoutingPriority(String region, String accountTier, Decimal amount) {
        // Enterprise accounts or large deals get high priority
        if (accountTier == 'Enterprise' || accountTier == 'Strategic' || 
            (amount != null && amount > 100000)) {
            return 'High';
        }
        
        // EMEA and APAC deals requiring special attention
        if (region == 'EMEA' || region == 'APAC') {
            return 'Medium';
        }
        
        return 'Low';
    }
    
    /**
     * @description Assigns opportunities to regional sales reps based on workload
     * @param opportunityIds List of Opportunity IDs to assign
     * @param region Target region for assignment
     */
    public static void assignToRegionalReps(List<Id> opportunityIds, String region) {
        if (opportunityIds == null || opportunityIds.isEmpty() || String.isBlank(region)) {
            return;
        }
        
        // Query opportunities that need assignment
        List<Opportunity> opportunities = [
            SELECT Id, OwnerId, SalesRegion__c, ForecastCategory__c
            FROM Opportunity
            WHERE Id IN :opportunityIds
            AND SalesRegion__c = :region
        ];
        
        // In a real implementation, this would query for available sales reps
        // and distribute opportunities based on workload balancing
        for (Opportunity opp : opportunities) {
            System.debug('Assigning opportunity ' + opp.Id + ' in region: ' + region);
        }
    }
    
    /**
     * @description Updates forecast categories based on opportunity stage
     * @param opportunityIds List of Opportunity IDs to update
     */
    public static void updateForecastCategories(List<Id> opportunityIds) {
        if (opportunityIds == null || opportunityIds.isEmpty()) {
            return;
        }
        
        List<Opportunity> opportunities = [
            SELECT Id, StageName, Probability, ForecastCategory__c
            FROM Opportunity
            WHERE Id IN :opportunityIds
        ];
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        for (Opportunity opp : opportunities) {
            String newCategory = calculateForecastCategory(opp.StageName, opp.Probability);
            
            if (newCategory != opp.ForecastCategory__c) {
                opp.ForecastCategory__c = newCategory;
                oppsToUpdate.add(opp);
            }
        }
        
        if (!oppsToUpdate.isEmpty()) {
            try {
                update oppsToUpdate;
            } catch (Exception e) {
                System.debug('Error updating forecast categories: ' + e.getMessage());
            }
        }
    }
    
    /**
     * @description Calculates forecast category based on stage and probability
     * @param stageName Opportunity stage
     * @param probability Win probability
     * @return String representing forecast category
     */
    private static String calculateForecastCategory(String stageName, Decimal probability) {
        if (probability == null) {
            return 'Omitted';
        }
        
        if (probability >= 90) {
            return 'Commit';
        } else if (probability >= 70) {
            return 'Best Case';
        } else if (probability > 0) {
            return 'Pipeline';
        }
        
        return 'Omitted';
    }
}
