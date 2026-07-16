public with sharing class TestDataEnrolleeFactory {
  // CareProgramEnrollee is the junction that puts a patient into a care program.
  // Unlike the other factories there is no model call here: the interesting
  // content of a junction row is its two foreign keys, not invented prose, and a
  // deterministic link is both correct and instant. It is also why this factory
  // requires an existing Patient and Care Program — the relationship is the point.
  private static final List<String> COVERAGE_TYPES = new List<String>{
    'NewEnrollee', 'ContinuedEnrollee'
  };
  private static final List<String> ENROLLEE_TYPES = new List<String>{
    'FullBenefitDual', 'PartialBenefitDual', 'NonDual', 'Dual'
  };

  @AuraEnabled
  public static TestDataHealthSupport.Result enrollPatient() {
    try {
      List<Account> patients = [
        SELECT Id, FirstName, LastName
        FROM Account
        WHERE IsPersonAccount = TRUE
        ORDER BY CreatedDate DESC
        LIMIT 50
      ];
      if (patients.isEmpty()) {
        throw new TestDataHealthSupport.TestDataHealthException(
          'Generate a Patient first — an enrollee links an existing patient to a care program.'
        );
      }

      List<CareProgram> programs = [SELECT Id, Name FROM CareProgram ORDER BY CreatedDate DESC LIMIT 50];
      if (programs.isEmpty()) {
        throw new TestDataHealthSupport.TestDataHealthException(
          'Generate a Care Program first — an enrollee links an existing patient to a care program.'
        );
      }

      Account patient = patients[(Integer) Math.floor(Math.random() * patients.size())];
      CareProgram program = programs[(Integer) Math.floor(Math.random() * programs.size())];

      String patientName = (String.isBlank(patient.FirstName) ? '' : patient.FirstName + ' ') + patient.LastName;
      CareProgramEnrollee enrollee = new CareProgramEnrollee();
      enrollee.Name = truncate(patientName + ' / ' + program.Name, 255);
      enrollee.CareProgramId = program.Id;
      enrollee.AccountId = patient.Id;
      enrollee.BenefitCoverageType = TestDataHealthSupport.pickRandom(COVERAGE_TYPES);
      enrollee.EnrolleeType = TestDataHealthSupport.pickRandom(ENROLLEE_TYPES);

      TestDataHealthSupport.requireCreateable(CareProgramEnrollee.SObjectType);
      insert enrollee;

      return new TestDataHealthSupport.Result(enrollee.Id, patientName, 'Enrolled in ' + program.Name);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static String truncate(String value, Integer maxLength) {
    return value.length() <= maxLength ? value : value.substring(0, maxLength);
  }
}
