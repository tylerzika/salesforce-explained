@IsTest
private class TestDataHealthFactoriesTest {
  // Replace the live Models call with a deterministic fake so each factory's
  // parse + map + DML contract is verified without external service behavior.
  // Same seam the Sales package uses: swap ModelsApiService.invoker.
  private class FakeInvoker extends ModelsApiService.ModelsInvoker {
    private final ModelsApiService.InvocationResult canned;

    FakeInvoker(ModelsApiService.InvocationResult canned) {
      this.canned = canned;
    }

    public override ModelsApiService.InvocationResult invokeChatGeneration(
      List<ModelsApiService.MessageInput> messages,
      String modelName
    ) {
      return canned;
    }
  }

  private static ModelsApiService.InvocationResult success(String text) {
    ModelsApiService.InvocationResult result = new ModelsApiService.InvocationResult();
    result.success = true;
    result.text = text;
    result.generationId = 'gen-test';
    return result;
  }

  private static ModelsApiService.InvocationResult failure(String code, String message) {
    ModelsApiService.InvocationResult result = new ModelsApiService.InvocationResult();
    result.success = false;
    result.errorCode = code;
    result.errorMessage = message;
    return result;
  }

  // ---- Patient (Person Account) --------------------------------------------

  @IsTest
  static void createsPatientFromModelJson() {
    String json =
      '{"FirstName":"Maria","LastName":"Alvarez","Birthdate":"1984-06-15",' +
      '"Email":"maria.alvarez@example.com","Phone":"555-0142",' +
      '"Street":"12 Oak Lane","City":"Asheville","State":"NC","PostalCode":"28801","Country":"USA"}';
    ModelsApiService.invoker = new FakeInvoker(success(json));

    Test.startTest();
    TestDataHealthSupport.Result result = TestDataPatientFactory.createPatient();
    Test.stopTest();

    System.assertNotEquals(null, result.recordId, 'Expected an inserted patient id');
    System.assertEquals('Maria Alvarez', result.name);

    Account patient = [
      SELECT FirstName, LastName, PersonEmail, PersonBirthdate, PersonMailingCity, IsPersonAccount
      FROM Account
      WHERE Id = :result.recordId
    ];
    System.assertEquals(true, patient.IsPersonAccount, 'Should insert as a Person Account');
    System.assertEquals('maria.alvarez@example.com', patient.PersonEmail, 'Email should map to PersonEmail');
    System.assertEquals('Asheville', patient.PersonMailingCity, 'Street/City should map to Person address');
    System.assertEquals(Date.newInstance(1984, 6, 15), patient.PersonBirthdate);
  }

  @IsTest
  static void fillsRequiredPatientNameWhenModelOmitsIt() {
    ModelsApiService.invoker = new FakeInvoker(success('{"City":"Denver"}'));

    Test.startTest();
    TestDataHealthSupport.Result result = TestDataPatientFactory.createPatient();
    Test.stopTest();

    Account patient = [SELECT LastName FROM Account WHERE Id = :result.recordId];
    System.assertEquals('Generated Patient', patient.LastName);
  }

  // ---- HealthcareProvider ---------------------------------------------------

  @IsTest
  static void createsProviderFromModelJson() {
    String json =
      '{"Name":"Blue Ridge Cardiology Group","ProviderType":"Medical Doctor",' +
      '"ProviderClass":"Medical Group","Status":"Active","TotalLicensedBeds":"0"}';
    ModelsApiService.invoker = new FakeInvoker(success(json));

    Test.startTest();
    TestDataHealthSupport.Result result = TestDataProviderFactory.createProvider();
    Test.stopTest();

    HealthcareProvider provider = [
      SELECT Name, ProviderType, ProviderClass, Status FROM HealthcareProvider WHERE Id = :result.recordId
    ];
    System.assertEquals('Blue Ridge Cardiology Group', provider.Name);
    System.assertEquals('Medical Doctor', provider.ProviderType);
    System.assertEquals('Medical Group', provider.ProviderClass);
    System.assertEquals('Active', provider.Status);
  }

  @IsTest
  static void stripsCodeFencesBeforeParsing() {
    String fenced = '```json\n{"Name":"Cedar Street Pharmacy","ProviderType":"Pharmacy"}\n```';
    ModelsApiService.invoker = new FakeInvoker(success(fenced));

    Test.startTest();
    TestDataHealthSupport.Result result = TestDataProviderFactory.createProvider();
    Test.stopTest();

    HealthcareProvider provider = [SELECT Name, ProviderType FROM HealthcareProvider WHERE Id = :result.recordId];
    System.assertEquals('Cedar Street Pharmacy', provider.Name);
    System.assertEquals('Pharmacy', provider.ProviderType);
  }

  @IsTest
  static void dropsInvalidProviderPicklistValues() {
    // Model ignored the allowed set ("Physician" is not a valid ProviderType).
    // The value must be dropped so the insert still succeeds.
    String json = '{"Name":"Elm Street Family Practice","ProviderType":"Physician","Status":"Bogus"}';
    ModelsApiService.invoker = new FakeInvoker(success(json));

    Test.startTest();
    TestDataHealthSupport.Result result = TestDataProviderFactory.createProvider();
    Test.stopTest();

    HealthcareProvider provider = [
      SELECT Name, ProviderType, Status FROM HealthcareProvider WHERE Id = :result.recordId
    ];
    System.assertEquals('Elm Street Family Practice', provider.Name);
    System.assertEquals(null, provider.ProviderType, 'Invalid picklist value should be dropped');
    System.assertEquals(null, provider.Status, 'Invalid picklist value should be dropped');
  }

  // ---- CareProgram ----------------------------------------------------------

  @IsTest
  static void createsCareProgramFromModelJson() {
    String json =
      '{"Name":"Heart Strong Cardiac Rehab","Description":"12-week cardiac recovery program.",' +
      '"Status":"In Progress","Category":"PatientServices","StartDate":"2026-01-10",' +
      '"EndDate":"2026-12-31","BudgetAmount":"$250,000","TargetEnrolleeCount":"150"}';
    ModelsApiService.invoker = new FakeInvoker(success(json));

    Test.startTest();
    TestDataHealthSupport.Result result = TestDataCareProgramFactory.createCareProgram();
    Test.stopTest();

    CareProgram program = [
      SELECT Name, Status, Category, StartDate, EndDate, BudgetAmount, TargetEnrolleeCount
      FROM CareProgram
      WHERE Id = :result.recordId
    ];
    System.assertEquals('Heart Strong Cardiac Rehab', program.Name);
    System.assertEquals('PatientServices', program.Category);
    System.assertEquals(Date.newInstance(2026, 1, 10), program.StartDate);
    System.assertEquals(250000, program.BudgetAmount, 'Currency symbols/commas should be stripped');
    System.assertEquals(150, program.TargetEnrolleeCount);
  }

  @IsTest
  static void dropsInvalidCareProgramCategory() {
    String json = '{"Name":"Wellness Path","Category":"NotACategory","Status":"Ongoing"}';
    ModelsApiService.invoker = new FakeInvoker(success(json));

    Test.startTest();
    TestDataHealthSupport.Result result = TestDataCareProgramFactory.createCareProgram();
    Test.stopTest();

    CareProgram program = [SELECT Name, Category, Status FROM CareProgram WHERE Id = :result.recordId];
    System.assertEquals('Wellness Path', program.Name);
    System.assertEquals(null, program.Category, 'Invalid category should be dropped');
    // Status carries a platform default ("New"), so the invalid value simply must
    // not have been applied — the record inserts cleanly either way.
    System.assertNotEquals('Ongoing', program.Status, 'Invalid status should not be applied');
  }

  // ---- CareProgramEnrollee (junction, no model call) -------------------------

  @IsTest
  static void enrollsExistingPatientIntoExistingProgram() {
    Id personType = [
      SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND IsPersonType = TRUE AND IsActive = TRUE LIMIT 1
    ]
    .Id;
    insert new Account(RecordTypeId = personType, FirstName = 'Ada', LastName = 'Lovelace');
    insert new CareProgram(Name = 'Cardiac Rehab');

    Test.startTest();
    TestDataHealthSupport.Result result = TestDataEnrolleeFactory.enrollPatient();
    Test.stopTest();

    CareProgramEnrollee enrollee = [
      SELECT Name, AccountId, CareProgramId, BenefitCoverageType, EnrolleeType
      FROM CareProgramEnrollee
      WHERE Id = :result.recordId
    ];
    System.assertNotEquals(null, enrollee.AccountId, 'Enrollee should link the patient');
    System.assertNotEquals(null, enrollee.CareProgramId, 'Enrollee should link the care program');
    System.assertEquals('Ada Lovelace / Cardiac Rehab', enrollee.Name);
    System.assertNotEquals(null, enrollee.EnrolleeType, 'EnrolleeType should be seeded');
  }

  @IsTest
  static void enrollRequiresAPatientToExist() {
    // No patient, no program — the junction must explain what's missing rather
    // than fail on a null foreign key.
    Test.startTest();
    Boolean threw = false;
    try {
      TestDataEnrolleeFactory.enrollPatient();
    } catch (AuraHandledException e) {
      threw = true;
    }
    Test.stopTest();

    System.assertEquals(true, threw, 'Enrolling with no patient should raise AuraHandledException');
    System.assertEquals(0, [SELECT COUNT() FROM CareProgramEnrollee], 'No enrollee should be created');
  }

  // ---- Overview counts ------------------------------------------------------

  @IsTest
  static void countsCoverEveryDiagramNode() {
    insert new CareProgram(Name = 'Counted Program');

    Test.startTest();
    Map<String, Integer> counts = TestDataHealthOverview.getCounts();
    Test.stopTest();

    System.assertEquals(true, counts.containsKey('patient'), 'patient count expected');
    System.assertEquals(true, counts.containsKey('provider'), 'provider count expected');
    System.assertEquals(true, counts.containsKey('enrollee'), 'enrollee count expected');
    System.assertEquals(1, counts.get('careProgram'), 'careProgram count should reflect inserted data');
  }

  // ---- Shared error contract ------------------------------------------------

  @IsTest
  static void surfacesModelFailureAsAuraHandledException() {
    ModelsApiService.invoker = new FakeInvoker(failure('HTTP_429', 'Rate limited'));

    Test.startTest();
    Boolean threw = false;
    try {
      TestDataProviderFactory.createProvider();
    } catch (AuraHandledException e) {
      threw = true;
    }
    Test.stopTest();

    System.assertEquals(true, threw, 'A failed generation should raise AuraHandledException');
    System.assertEquals(0, [SELECT COUNT() FROM HealthcareProvider], 'No provider should be inserted on failure');
  }

  @IsTest
  static void malformedJsonRaises() {
    ModelsApiService.invoker = new FakeInvoker(success('not-json-at-all'));

    Test.startTest();
    Boolean threw = false;
    try {
      TestDataCareProgramFactory.createCareProgram();
    } catch (AuraHandledException e) {
      threw = true;
    }
    Test.stopTest();

    System.assertEquals(true, threw, 'Unparseable payload should raise AuraHandledException');
  }
}
