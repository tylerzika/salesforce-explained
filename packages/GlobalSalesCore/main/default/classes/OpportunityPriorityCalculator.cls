/**
 * @description Simple utility class for calculating opportunity priority
 * This class is designed to be called from Flows in dependent packages
 * @author Salesforce Explained
 */
public with sharing class OpportunityPriorityCalculator {
    
    /**
     * @description Invocable method to calculate priority for opportunities
     * Can be called from Flow to demonstrate cross-package integration
     * @param requests List of opportunity IDs to process
     * @return List of results with calculated priority
     */
    @InvocableMethod(label='Calculate Opportunity Priority' 
                     description='Calculates priority based on amount and region'
                     category='Opportunity')
    public static List<Result> calculatePriority(List<Request> requests) {
        List<Result> results = new List<Result>();
        
        // Get opportunity IDs
        Set<Id> oppIds = new Set<Id>();
        for (Request req : requests) {
            oppIds.add(req.opportunityId);
        }
        
        // Query opportunities
        Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([
            SELECT Id, Amount, SalesRegion__c, Account.Type
            FROM Opportunity
            WHERE Id IN :oppIds
        ]);
        
        // Calculate priority for each
        for (Request req : requests) {
            Opportunity opp = opportunities.get(req.opportunityId);
            Result res = new Result();
            res.opportunityId = req.opportunityId;
            
            if (opp != null) {
                res.priority = determinePriority(opp);
            } else {
                res.priority = 'Low';
            }
            
            results.add(res);
        }
        
        return results;
    }
    
    /**
     * @description Determines priority based on opportunity attributes
     * @param opp Opportunity record
     * @return Priority level (High, Medium, Low)
     */
    private static String determinePriority(Opportunity opp) {
        // High priority: Large deals or strategic accounts
        if (opp.Amount != null && opp.Amount > 100000) {
            return 'High';
        }
        
        // Medium priority: EMEA or APAC regions
        if (opp.SalesRegion__c == 'EMEA' || opp.SalesRegion__c == 'APAC') {
            return 'Medium';
        }
        
        // Default to Low
        return 'Low';
    }
    
    /**
     * Inner class for invocable method input
     */
    public class Request {
        @InvocableVariable(required=true label='Opportunity ID')
        public Id opportunityId;
    }
    
    /**
     * Inner class for invocable method output
     */
    public class Result {
        @InvocableVariable(label='Opportunity ID')
        public Id opportunityId;
        
        @InvocableVariable(label='Priority')
        public String priority;
    }
}
