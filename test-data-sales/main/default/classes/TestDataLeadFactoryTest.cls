@IsTest
private class TestDataLeadFactoryTest {
  // Replace the live Models call with a deterministic fake so the factory's
  // parse + map + DML contract is verified without external service behavior.
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

  @IsTest
  static void createsLeadFromModelJson() {
    String json =
      '{"FirstName":"Dana","LastName":"Okafor","Company":"Northwind Robotics",' +
      '"Title":"VP Operations","Email":"dana@northwindrobotics.com","Industry":"Manufacturing",' +
      '"LeadSource":"Web","Rating":"Warm","AnnualRevenue":"$4,200,000","NumberOfEmployees":"85"}';
    ModelsApiService.invoker = new FakeInvoker(success(json));

    Test.startTest();
    TestDataLeadFactory.LeadResult result = TestDataLeadFactory.createLead();
    Test.stopTest();

    System.assertNotEquals(null, result.leadId, 'Expected an inserted lead id');
    System.assertEquals('Dana Okafor', result.name, 'Name should combine first and last name');
    System.assertEquals('Northwind Robotics', result.company);

    Lead inserted = [
      SELECT FirstName, LastName, Company, Industry, AnnualRevenue, NumberOfEmployees
      FROM Lead
      WHERE Id = :result.leadId
    ];
    System.assertEquals('Manufacturing', inserted.Industry);
    System.assertEquals(4200000, inserted.AnnualRevenue, 'Currency symbols/commas should be stripped');
    System.assertEquals(85, inserted.NumberOfEmployees);
  }

  @IsTest
  static void stripsCodeFencesBeforeParsing() {
    String fenced = '```json\n{"LastName":"Reyes","Company":"Acme Freight"}\n```';
    ModelsApiService.invoker = new FakeInvoker(success(fenced));

    Test.startTest();
    TestDataLeadFactory.LeadResult result = TestDataLeadFactory.createLead();
    Test.stopTest();

    Lead inserted = [SELECT LastName, Company FROM Lead WHERE Id = :result.leadId];
    System.assertEquals('Reyes', inserted.LastName);
    System.assertEquals('Acme Freight', inserted.Company);
  }

  @IsTest
  static void fillsRequiredFieldsWhenModelOmitsThem() {
    ModelsApiService.invoker = new FakeInvoker(success('{"Title":"Analyst"}'));

    Test.startTest();
    TestDataLeadFactory.LeadResult result = TestDataLeadFactory.createLead();
    Test.stopTest();

    Lead inserted = [SELECT LastName, Company, Title FROM Lead WHERE Id = :result.leadId];
    System.assertEquals('Generated Lead', inserted.LastName);
    System.assertEquals('Unknown Company', inserted.Company);
    System.assertEquals('Analyst', inserted.Title);
  }

  @IsTest
  static void surfacesModelFailureAsAuraHandledException() {
    ModelsApiService.invoker = new FakeInvoker(failure('HTTP_429', 'Rate limited'));

    Test.startTest();
    Boolean threw = false;
    try {
      TestDataLeadFactory.createLead();
    } catch (AuraHandledException e) {
      threw = true;
    }
    Test.stopTest();

    System.assertEquals(true, threw, 'A failed generation should raise AuraHandledException');
    System.assertEquals(0, [SELECT COUNT() FROM Lead], 'No lead should be inserted on failure');
  }

  @IsTest
  static void malformedJsonRaises() {
    ModelsApiService.invoker = new FakeInvoker(success('not-json-at-all'));

    Test.startTest();
    Boolean threw = false;
    try {
      TestDataLeadFactory.createLead();
    } catch (AuraHandledException e) {
      threw = true;
    }
    Test.stopTest();

    System.assertEquals(true, threw, 'Unparseable payload should raise AuraHandledException');
  }
}
