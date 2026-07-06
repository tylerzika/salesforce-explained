public with sharing class TestDataLeadFactory {
  // Ask the model for a single realistic B2B lead. We constrain the shape to a
  // strict JSON object so the Apex side stays a deterministic parser: the
  // stochastic step is bounded to "invent plausible field values", everything
  // after the boundary is ordinary validation + DML.
  private static final String SYSTEM_PROMPT =
    'You generate realistic but entirely fictional B2B sales lead records for a Salesforce demo org. ' +
    'Return ONLY a single minified JSON object. No prose, no markdown, no code fences. ' +
    'Use these keys exactly: FirstName, LastName, Company, Title, Email, Phone, Website, ' +
    'Industry, LeadSource, Rating, Street, City, State, PostalCode, Country, ' +
    'AnnualRevenue, NumberOfEmployees, Description. ' +
    'AnnualRevenue is a whole number of US dollars. NumberOfEmployees is a whole number. ' +
    'Industry should be a common Salesforce Industry picklist value (e.g. Technology, Manufacturing, Finance). ' +
    'LeadSource should be a common value (e.g. Web, Phone Inquiry, Partner Referral). ' +
    'Rating is one of Hot, Warm, Cold. Email must be a plausible business address for the Company.';

  // Randomized nudges so each click diverges instead of the model settling into
  // one "average" lead. Apex picks the seeds (not the model), which guarantees
  // spread even though a single generation is otherwise fairly deterministic.
  private static final List<String> INDUSTRIES = new List<String>{
    'Agriculture', 'Banking', 'Biotechnology', 'Construction', 'Consulting',
    'Education', 'Energy', 'Finance', 'Food & Beverage', 'Government',
    'Healthcare', 'Hospitality', 'Insurance', 'Manufacturing', 'Media',
    'Retail', 'Technology', 'Telecommunications', 'Transportation', 'Utilities'
  };

  private static final List<String> REGIONS = new List<String>{
    'the United States', 'Canada', 'the United Kingdom', 'Germany', 'France',
    'the Netherlands', 'Sweden', 'Australia', 'Japan', 'Singapore', 'Brazil', 'India'
  };

  private static final List<String> COMPANY_SIZES = new List<String>{
    'a bootstrapped startup (5-25 employees)',
    'an early-stage scaleup (30-90 employees)',
    'a mid-market company (200-900 employees)',
    'a large enterprise (3,000-15,000 employees)'
  };

  private static final List<String> DEPARTMENTS = new List<String>{
    'Operations', 'Marketing', 'Sales', 'IT', 'Finance', 'Procurement',
    'Product', 'Engineering', 'Customer Success', 'Human Resources'
  };

  private static final List<String> LEAD_SOURCES = new List<String>{
    'Web', 'Phone Inquiry', 'Partner Referral', 'Purchased List', 'Trade Show', 'Other'
  };

  // Standard Lead fields we are willing to populate from model output. Anything
  // outside this allowlist is ignored so a hallucinated key can never reach DML.
  private static final Set<String> TEXT_FIELDS = new Set<String>{
    'FirstName', 'LastName', 'Company', 'Title', 'Email', 'Phone', 'Website',
    'Industry', 'LeadSource', 'Rating', 'Street', 'City', 'State', 'PostalCode', 'Country', 'Description'
  };

  public class TestDataLeadException extends Exception {
  }

  // Compact result the list-view action can drop straight into a toast.
  public class LeadResult {
    @AuraEnabled
    public Id leadId;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String company;
  }

  @AuraEnabled
  public static LeadResult createLead() {
    try {
      Lead lead = buildLeadFromModel();
      insertLead(lead);

      LeadResult result = new LeadResult();
      result.leadId = lead.Id;
      result.name = (String.isBlank(lead.FirstName) ? '' : lead.FirstName + ' ') + lead.LastName;
      result.company = lead.Company;
      return result;
    } catch (Exception e) {
      // Surface a clean message to the LWC/Aura layer instead of a raw stack.
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static Lead buildLeadFromModel() {
    List<ModelsApiService.MessageInput> messages = new List<ModelsApiService.MessageInput>{
      new ModelsApiService.MessageInput('system', SYSTEM_PROMPT),
      new ModelsApiService.MessageInput('user', buildUserPrompt())
    };

    // Small models occasionally return an empty ```json fence or otherwise
    // unparseable text. That is transient, so give the parse one retry before
    // surfacing an error to the user; provider failures are not retried here.
    TestDataLeadException lastParseError;
    for (Integer attempt = 0; attempt < 2; attempt++) {
      ModelsApiService.GenerationResult generation = ModelsApiService.generateFromMessages(messages);
      if (generation == null || !generation.success) {
        String code = generation == null ? 'NO_RESPONSE' : generation.errorCode;
        String message = generation == null ? 'The Models API returned no response.' : generation.errorMessage;
        throw new TestDataLeadException('Lead generation failed (' + code + '): ' + message);
      }

      try {
        return mapToLead(parseLeadJson(generation.text));
      } catch (TestDataLeadException e) {
        lastParseError = e;
      }
    }
    throw lastParseError;
  }

  // Assemble a per-invocation prompt seeded with random dimensions so repeated
  // clicks produce meaningfully different leads (industry, geography, size,
  // buyer department, source) instead of variations on one archetype.
  private static String buildUserPrompt() {
    String industry = pickRandom(INDUSTRIES);
    String region = pickRandom(REGIONS);
    String size = pickRandom(COMPANY_SIZES);
    String department = pickRandom(DEPARTMENTS);
    String source = pickRandom(LEAD_SOURCES);
    String seed = String.valueOf(Crypto.getRandomInteger());

    return 'Generate one new lead now. Make the company, person, and numbers internally consistent. ' +
      'Use these seeds so it differs from other generated leads: ' +
      'Industry = ' + industry + '; ' +
      'company headquartered in ' + region + '; ' +
      'company size ' + size + '; ' +
      'the contact works in ' + department + ' at a seniority you choose; ' +
      'LeadSource = ' + source + '. ' +
      'Pick a distinctive, non-generic company and person name. Variation seed: ' + seed + '.';
  }

  private static String pickRandom(List<String> options) {
    Integer index = (Integer) Math.floor(Math.random() * options.size());
    return options[index];
  }

  // Models routinely wrap JSON in ```json fences or add stray prose even when
  // told not to. Rather than fight every wrapper, isolate the outermost JSON
  // object by its braces — this handles fences, prose, and leading/trailing junk
  // uniformly, and fails cleanly when there is no object at all (e.g. an empty
  // ```json fence, which we retry a level up).
  @TestVisible
  private static Map<String, Object> parseLeadJson(String rawText) {
    if (String.isBlank(rawText)) {
      throw new TestDataLeadException('The model returned an empty lead payload.');
    }

    Integer firstBrace = rawText.indexOf('{');
    Integer lastBrace = rawText.lastIndexOf('}');
    if (firstBrace < 0 || lastBrace <= firstBrace) {
      throw new TestDataLeadException('The model response did not contain a JSON object.');
    }

    String cleaned = rawText.substring(firstBrace, lastBrace + 1);
    try {
      return (Map<String, Object>) JSON.deserializeUntyped(cleaned);
    } catch (Exception e) {
      throw new TestDataLeadException('Could not parse the generated lead as JSON: ' + e.getMessage());
    }
  }

  private static Lead mapToLead(Map<String, Object> values) {
    Lead lead = new Lead();

    for (String field : TEXT_FIELDS) {
      String value = asText(values.get(field));
      if (value != null) {
        lead.put(field, value);
      }
    }

    Decimal annualRevenue = asDecimal(values.get('AnnualRevenue'));
    if (annualRevenue != null) {
      lead.AnnualRevenue = annualRevenue;
    }

    Integer employees = asInteger(values.get('NumberOfEmployees'));
    if (employees != null) {
      lead.NumberOfEmployees = employees;
    }

    // LastName + Company are required on Lead; guarantee them so a thin model
    // response still produces an insertable record.
    if (String.isBlank(lead.LastName)) {
      lead.LastName = 'Generated Lead';
    }
    if (String.isBlank(lead.Company)) {
      lead.Company = 'Unknown Company';
    }

    return lead;
  }

  private static void insertLead(Lead lead) {
    if (!Schema.sObjectType.Lead.isCreateable()) {
      throw new TestDataLeadException('You do not have permission to create Lead records.');
    }
    insert lead;
  }

  private static String asText(Object value) {
    if (value == null) {
      return null;
    }
    String text = String.valueOf(value).trim();
    return String.isBlank(text) ? null : text;
  }

  private static Decimal asDecimal(Object value) {
    String text = asText(value);
    if (text == null) {
      return null;
    }
    try {
      // Strip anything that is not part of a number (e.g. "$1,200,000").
      String digits = text.replaceAll('[^0-9.\\-]', '');
      return String.isBlank(digits) ? null : Decimal.valueOf(digits);
    } catch (Exception e) {
      return null;
    }
  }

  private static Integer asInteger(Object value) {
    Decimal numeric = asDecimal(value);
    return numeric == null ? null : numeric.intValue();
  }
}
