public with sharing class TestDataHealthSupport {
  // Shared mechanics for the Health Cloud test-data factories. The Sales package
  // put all of this inline in a single object's factory; Health Cloud spans many
  // objects, so the model call + JSON isolation + coercion live here once and each
  // per-object factory stays thin: it owns only its prompt, field allowlist, and
  // sObject mapping. The stochastic step is still bounded to "invent plausible
  // field values"; everything past parseJson() is deterministic validation + DML.

  public class TestDataHealthException extends Exception {
  }

  // Compact result every factory returns; the LWC drops it straight into a toast.
  public class Result {
    @AuraEnabled
    public Id recordId;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String detail;

    public Result(Id recordId, String name, String detail) {
      this.recordId = recordId;
      this.name = name;
      this.detail = detail;
    }
  }

  // Run the model with a system + user prompt and return the parsed JSON object.
  // Small models occasionally return an empty ```json fence or otherwise
  // unparseable text; that is transient, so the parse gets one retry. Provider
  // failures (rate limits, auth) are not retried — they surface immediately.
  public static Map<String, Object> generateJson(String systemPrompt, String userPrompt) {
    List<ModelsApiService.MessageInput> messages = new List<ModelsApiService.MessageInput>{
      new ModelsApiService.MessageInput('system', systemPrompt),
      new ModelsApiService.MessageInput('user', userPrompt)
    };

    TestDataHealthException lastParseError;
    for (Integer attempt = 0; attempt < 2; attempt++) {
      ModelsApiService.GenerationResult generation = ModelsApiService.generateFromMessages(messages);
      if (generation == null || !generation.success) {
        String code = generation == null ? 'NO_RESPONSE' : generation.errorCode;
        String message = generation == null ? 'The Models API returned no response.' : generation.errorMessage;
        throw new TestDataHealthException('Generation failed (' + code + '): ' + message);
      }

      try {
        return parseJson(generation.text);
      } catch (TestDataHealthException e) {
        lastParseError = e;
      }
    }
    throw lastParseError;
  }

  // Models routinely wrap JSON in ```json fences or add stray prose even when told
  // not to. Isolate the outermost JSON object by its braces — this handles fences,
  // prose, and leading/trailing junk uniformly, and fails cleanly when there is no
  // object at all (e.g. an empty ```json fence, which we retry a level up).
  @TestVisible
  private static Map<String, Object> parseJson(String rawText) {
    if (String.isBlank(rawText)) {
      throw new TestDataHealthException('The model returned an empty payload.');
    }

    Integer firstBrace = rawText.indexOf('{');
    Integer lastBrace = rawText.lastIndexOf('}');
    if (firstBrace < 0 || lastBrace <= firstBrace) {
      throw new TestDataHealthException('The model response did not contain a JSON object.');
    }

    String cleaned = rawText.substring(firstBrace, lastBrace + 1);
    try {
      return (Map<String, Object>) JSON.deserializeUntyped(cleaned);
    } catch (Exception e) {
      throw new TestDataHealthException('Could not parse the generated record as JSON: ' + e.getMessage());
    }
  }

  // Copy allowlisted string values from the model output onto the record. Anything
  // outside the allowlist is ignored so a hallucinated key can never reach DML.
  public static void applyText(SObject record, Map<String, Object> values, Set<String> allow) {
    for (String field : allow) {
      String value = asText(values.get(field));
      if (value != null) {
        record.put(field, value);
      }
    }
  }

  public static String pickRandom(List<String> options) {
    Integer index = (Integer) Math.floor(Math.random() * options.size());
    return options[index];
  }

  // Restricted picklists reject any value outside their defined set, so a model
  // that ignores the prompt (e.g. "Physician" instead of "Medical Doctor") would
  // fail the whole insert. Match the model's value case-insensitively against the
  // allowed set and return the canonical casing, or null to leave the field unset.
  public static String pickValid(Object value, Set<String> allowed) {
    String text = asText(value);
    if (text == null) {
      return null;
    }
    for (String option : allowed) {
      if (option.equalsIgnoreCase(text)) {
        return option;
      }
    }
    return null;
  }

  public static String seed() {
    return String.valueOf(Crypto.getRandomInteger());
  }

  public static void requireCreateable(Schema.SObjectType type) {
    if (!type.getDescribe().isCreateable()) {
      throw new TestDataHealthException(
        'You do not have permission to create ' + type.getDescribe().getLabel() + ' records.'
      );
    }
  }

  public static String asText(Object value) {
    if (value == null) {
      return null;
    }
    String text = String.valueOf(value).trim();
    return String.isBlank(text) ? null : text;
  }

  public static Decimal asDecimal(Object value) {
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

  public static Integer asInteger(Object value) {
    Decimal numeric = asDecimal(value);
    return numeric == null ? null : numeric.intValue();
  }

  // Health Cloud records carry many dates (birthdate, program start/end). Accept
  // the ISO 'yyyy-MM-dd' the prompts ask for; anything unparseable is dropped
  // rather than failing the whole insert.
  public static Date asDate(Object value) {
    String text = asText(value);
    if (text == null) {
      return null;
    }
    try {
      return Date.valueOf(text);
    } catch (Exception e) {
      return null;
    }
  }
}
