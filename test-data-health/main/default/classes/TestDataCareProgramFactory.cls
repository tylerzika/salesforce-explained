public with sharing class TestDataCareProgramFactory {
  // Generates one fictional CareProgram — a structured health program patients
  // enroll into (disease management, patient services, clinical trial support).
  // Name is the only required field; picklists are constrained by the prompt.
  private static final String SYSTEM_PROMPT =
    'You generate realistic but entirely fictional care program records for a Salesforce Health Cloud demo org. ' +
    'A care program is a structured health initiative patients enroll into. ' +
    'Return ONLY a single minified JSON object. No prose, no markdown, no code fences. ' +
    'Use these keys exactly: Name, Description, Status, Category, StartDate, EndDate, BudgetAmount, TargetEnrolleeCount. ' +
    'Status must be one of: New, In Progress, Completed, Canceled. ' +
    'Category must be one of: AdvancedTherapy, TrialManagement, PatientServices. ' +
    'StartDate and EndDate are ISO dates (yyyy-MM-dd) with EndDate after StartDate. ' +
    'BudgetAmount is a whole number of US dollars. TargetEnrolleeCount is a whole number. ' +
    'Description is one or two sentences. Name should be a distinctive, non-generic program name.';

  private static final List<String> THEMES = new List<String>{
    'diabetes management', 'cardiac rehabilitation', 'maternal and infant health',
    'oncology patient support', 'behavioral health', 'chronic pain management',
    'smoking cessation', 'post-surgical recovery', 'a rare-disease therapy trial',
    'medication adherence'
  };

  private static final Set<String> TEXT_FIELDS = new Set<String>{ 'Name', 'Description' };

  // Restricted picklists on CareProgram — model values outside these sets are
  // dropped (pickValid) rather than risking an insert failure.
  private static final Set<String> STATUSES = new Set<String>{
    'New', 'In Progress', 'Completed', 'Canceled'
  };
  private static final Set<String> CATEGORIES = new Set<String>{
    'AdvancedTherapy', 'TrialManagement', 'PatientServices'
  };

  @AuraEnabled
  public static TestDataHealthSupport.Result createCareProgram() {
    try {
      Map<String, Object> values = TestDataHealthSupport.generateJson(SYSTEM_PROMPT, buildUserPrompt());
      CareProgram program = mapToCareProgram(values);

      TestDataHealthSupport.requireCreateable(CareProgram.SObjectType);
      insert program;

      return new TestDataHealthSupport.Result(
        program.Id,
        program.Name,
        String.isBlank(program.Category) ? 'Care Program' : program.Category
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static String buildUserPrompt() {
    String theme = TestDataHealthSupport.pickRandom(THEMES);
    return 'Generate one new care program now focused on ' + theme + '. ' +
      'Choose a Category consistent with that theme. ' +
      'Variation seed: ' + TestDataHealthSupport.seed() + '.';
  }

  private static CareProgram mapToCareProgram(Map<String, Object> values) {
    CareProgram program = new CareProgram();
    TestDataHealthSupport.applyText(program, values, TEXT_FIELDS);

    String status = TestDataHealthSupport.pickValid(values.get('Status'), STATUSES);
    if (status != null) {
      program.Status = status;
    }
    String category = TestDataHealthSupport.pickValid(values.get('Category'), CATEGORIES);
    if (category != null) {
      program.Category = category;
    }

    Date startDate = TestDataHealthSupport.asDate(values.get('StartDate'));
    if (startDate != null) {
      program.StartDate = startDate;
    }
    Date endDate = TestDataHealthSupport.asDate(values.get('EndDate'));
    if (endDate != null) {
      program.EndDate = endDate;
    }
    Decimal budget = TestDataHealthSupport.asDecimal(values.get('BudgetAmount'));
    if (budget != null) {
      program.BudgetAmount = budget;
    }
    Integer target = TestDataHealthSupport.asInteger(values.get('TargetEnrolleeCount'));
    if (target != null) {
      program.TargetEnrolleeCount = target;
    }

    // Name is required; guarantee it so a thin model response still inserts.
    if (String.isBlank(program.Name)) {
      program.Name = 'Generated Care Program';
    }
    return program;
  }
}
