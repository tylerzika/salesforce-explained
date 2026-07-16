public with sharing class TestDataPatientFactory {
  // A Health Cloud "patient" is a Person Account — an Account row carrying person
  // fields and the Person Account record type. This factory generates one
  // fictional patient and inserts it. Mechanics (model call, JSON isolation,
  // coercion) live in TestDataHealthSupport; this class owns only the prompt,
  // field allowlist, and the Person Account mapping.
  private static final String SYSTEM_PROMPT =
    'You generate realistic but entirely fictional patient records for a Salesforce Health Cloud demo org. ' +
    'These are Person Accounts. Return ONLY a single minified JSON object. No prose, no markdown, no code fences. ' +
    'Use these keys exactly: FirstName, LastName, Birthdate, Email, Phone, ' +
    'Street, City, State, PostalCode, Country. ' +
    'Birthdate is an ISO date (yyyy-MM-dd) for a person between 1 and 95 years old. ' +
    'Email must be a plausible personal address for the person. ' +
    'Do not use real people. Keep every value internally consistent (name, email, address).';

  private static final List<String> REGIONS = new List<String>{
    'the Northeast US', 'the Midwest US', 'the Southern US', 'the West Coast US',
    'the Pacific Northwest', 'the Mountain West', 'the Mid-Atlantic US'
  };

  private static final List<String> LIFE_STAGES = new List<String>{
    'a young adult in their 20s', 'an adult in their 30s', 'a middle-aged adult in their 40s or 50s',
    'an older adult in their 60s', 'a senior over 70', 'a pediatric patient under 18'
  };

  // Standard Person Account fields we will populate from model output. Anything
  // outside this allowlist is ignored so a hallucinated key can never reach DML.
  private static final Set<String> TEXT_FIELDS = new Set<String>{
    'FirstName', 'LastName', 'PersonEmail', 'Phone',
    'PersonMailingStreet', 'PersonMailingCity', 'PersonMailingState',
    'PersonMailingPostalCode', 'PersonMailingCountry'
  };

  @AuraEnabled
  public static TestDataHealthSupport.Result createPatient() {
    try {
      Map<String, Object> values = TestDataHealthSupport.generateJson(SYSTEM_PROMPT, buildUserPrompt());
      Account patient = mapToPatient(values);

      TestDataHealthSupport.requireCreateable(Account.SObjectType);
      insert patient;

      String fullName = (String.isBlank(patient.FirstName) ? '' : patient.FirstName + ' ') + patient.LastName;
      String detail = patient.PersonBirthdate == null
        ? 'Person Account'
        : 'DOB ' + String.valueOf(patient.PersonBirthdate);
      return new TestDataHealthSupport.Result(patient.Id, fullName, detail);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static String buildUserPrompt() {
    String region = TestDataHealthSupport.pickRandom(REGIONS);
    String stage = TestDataHealthSupport.pickRandom(LIFE_STAGES);
    return 'Generate one new patient now. The patient is ' + stage + ', living in ' + region + '. ' +
      'Pick a distinctive, non-generic name and a birthdate consistent with that life stage. ' +
      'Variation seed: ' + TestDataHealthSupport.seed() + '.';
  }

  private static Account mapToPatient(Map<String, Object> values) {
    // The keys the model returns don't all match the Person Account API names
    // (Email -> PersonEmail, Street -> PersonMailingStreet, ...); remap the
    // person-address/contact keys before the allowlisted copy.
    Map<String, Object> remapped = new Map<String, Object>{
      'FirstName' => values.get('FirstName'),
      'LastName' => values.get('LastName'),
      'PersonEmail' => values.get('Email'),
      'Phone' => values.get('Phone'),
      'PersonMailingStreet' => values.get('Street'),
      'PersonMailingCity' => values.get('City'),
      'PersonMailingState' => values.get('State'),
      'PersonMailingPostalCode' => values.get('PostalCode'),
      'PersonMailingCountry' => values.get('Country')
    };

    Account patient = new Account();
    patient.RecordTypeId = personAccountRecordTypeId();
    TestDataHealthSupport.applyText(patient, remapped, TEXT_FIELDS);

    Date birthdate = TestDataHealthSupport.asDate(values.get('Birthdate'));
    if (birthdate != null) {
      patient.PersonBirthdate = birthdate;
    }

    // LastName is required on Person Accounts; guarantee it so a thin model
    // response still produces an insertable record.
    if (String.isBlank(patient.LastName)) {
      patient.LastName = 'Generated Patient';
    }
    return patient;
  }

  private static Id personAccountRecordTypeId() {
    List<RecordType> types = [
      SELECT Id
      FROM RecordType
      WHERE SObjectType = 'Account' AND IsPersonType = TRUE AND IsActive = TRUE
      LIMIT 1
    ];
    if (types.isEmpty()) {
      throw new TestDataHealthSupport.TestDataHealthException(
        'No active Person Account record type is available in this org.'
      );
    }
    return types[0].Id;
  }
}
