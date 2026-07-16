public with sharing class TestDataProviderFactory {
  // Generates one fictional HealthcareProvider (a clinician or care organization).
  // Name is the only truly required field; the rest are constrained to real
  // picklist values so the generated data stays valid.
  private static final String SYSTEM_PROMPT =
    'You generate realistic but entirely fictional healthcare provider records for a Salesforce Health Cloud demo org. ' +
    'A provider is a clinician or care organization. Return ONLY a single minified JSON object. ' +
    'No prose, no markdown, no code fences. Use these keys exactly: ' +
    'Name, ProviderType, ProviderClass, Status, ProfessionalTitle, TotalLicensedBeds. ' +
    'ProviderType must be one of: Hospital, Ambulatory Care, Laboratory, Pharmacy, Dentist, Pharmacist, Medical Doctor. ' +
    'ProviderClass must be one of: IPA, Medical Group, Solo Practitioner. ' +
    'Status must be one of: Active, Inactive, Pending. ' +
    'ProfessionalTitle is a short credential string (e.g. MD, DO, RN, PharmD) or empty for organizations. ' +
    'TotalLicensedBeds is a whole number, only meaningful for Hospital providers; use 0 otherwise. ' +
    'Name should read like a real practice, hospital, or "Dr. Firstname Lastname" — distinctive, not generic.';

  private static final List<String> PROVIDER_KINDS = new List<String>{
    'a large hospital', 'a community clinic', 'a solo primary-care physician',
    'a specialist medical group', 'a retail pharmacy', 'a diagnostic laboratory',
    'a dental practice', 'an urgent care center'
  };

  private static final List<String> SPECIALTIES = new List<String>{
    'primary care', 'cardiology', 'oncology', 'pediatrics', 'orthopedics',
    'neurology', 'dermatology', 'endocrinology', 'family medicine', 'internal medicine'
  };

  // Free-text fields we will copy straight through from the allowlist.
  private static final Set<String> TEXT_FIELDS = new Set<String>{ 'Name' };

  // Restricted picklists on HealthcareProvider — a model value outside these sets
  // is dropped (pickValid) rather than risking an insert failure.
  private static final Set<String> PROVIDER_TYPES = new Set<String>{
    'Hospital', 'Ambulatory Care', 'Laboratory', 'Pharmacy', 'Dentist', 'Pharmacist', 'Medical Doctor'
  };
  private static final Set<String> PROVIDER_CLASSES = new Set<String>{
    'IPA', 'Medical Group', 'Solo Practitioner'
  };
  private static final Set<String> STATUSES = new Set<String>{ 'Active', 'Inactive', 'Pending' };

  @AuraEnabled
  public static TestDataHealthSupport.Result createProvider() {
    try {
      Map<String, Object> values = TestDataHealthSupport.generateJson(SYSTEM_PROMPT, buildUserPrompt());
      HealthcareProvider provider = mapToProvider(values);

      TestDataHealthSupport.requireCreateable(HealthcareProvider.SObjectType);
      insert provider;

      return new TestDataHealthSupport.Result(
        provider.Id,
        provider.Name,
        String.isBlank(provider.ProviderType) ? 'Provider' : provider.ProviderType
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static String buildUserPrompt() {
    String kind = TestDataHealthSupport.pickRandom(PROVIDER_KINDS);
    String specialty = TestDataHealthSupport.pickRandom(SPECIALTIES);
    return 'Generate one new healthcare provider now: ' + kind + ' focused on ' + specialty + '. ' +
      'Make the ProviderType and ProviderClass consistent with that kind of provider. ' +
      'Variation seed: ' + TestDataHealthSupport.seed() + '.';
  }

  private static HealthcareProvider mapToProvider(Map<String, Object> values) {
    HealthcareProvider provider = new HealthcareProvider();
    TestDataHealthSupport.applyText(provider, values, TEXT_FIELDS);

    String providerType = TestDataHealthSupport.pickValid(values.get('ProviderType'), PROVIDER_TYPES);
    if (providerType != null) {
      provider.ProviderType = providerType;
    }
    String providerClass = TestDataHealthSupport.pickValid(values.get('ProviderClass'), PROVIDER_CLASSES);
    if (providerClass != null) {
      provider.ProviderClass = providerClass;
    }
    String status = TestDataHealthSupport.pickValid(values.get('Status'), STATUSES);
    if (status != null) {
      provider.Status = status;
    }

    Integer beds = TestDataHealthSupport.asInteger(values.get('TotalLicensedBeds'));
    if (beds != null && beds > 0) {
      provider.TotalLicensedBeds = beds;
    }

    // Name is required; guarantee it so a thin model response still inserts.
    if (String.isBlank(provider.Name)) {
      provider.Name = 'Generated Provider';
    }
    return provider;
  }
}
