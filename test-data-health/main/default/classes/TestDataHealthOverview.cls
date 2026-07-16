public with sharing class TestDataHealthOverview {
  // Live record counts for the schema diagram, so each node shows how much data
  // it currently holds. Cacheable so the LWC can @wire it and refreshApex after
  // a generate.
  @AuraEnabled(cacheable=true)
  public static Map<String, Integer> getCounts() {
    return new Map<String, Integer>{
      'patient' => [SELECT COUNT() FROM Account WHERE IsPersonAccount = TRUE],
      'provider' => [SELECT COUNT() FROM HealthcareProvider],
      'careProgram' => [SELECT COUNT() FROM CareProgram],
      'enrollee' => [SELECT COUNT() FROM CareProgramEnrollee]
    };
  }
}
