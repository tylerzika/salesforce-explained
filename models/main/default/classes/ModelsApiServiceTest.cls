@isTest
private class ModelsApiServiceTest {
  // The fake invoker makes the suite deterministic. We are testing our wrapper
  // contract, not Salesforce's hosted model behavior.
  private class FakeModelsInvoker extends ModelsApiService.ModelsInvoker {
    private Boolean shouldFail;
    private String nextText;
    private String nextGenerationId;
    private String nextErrorCode;
    private String nextErrorMessage;
    private String lastModelName;

    FakeModelsInvoker(Boolean shouldFail, String nextText, String nextGenerationId, String nextErrorCode, String nextErrorMessage) {
      this.shouldFail = shouldFail;
      this.nextText = nextText;
      this.nextGenerationId = nextGenerationId;
      this.nextErrorCode = nextErrorCode;
      this.nextErrorMessage = nextErrorMessage;
    }

    public override ModelsApiService.InvocationResult invokeGeneration(String promptText, String modelName) {
      lastModelName = modelName;
      return buildResult();
    }

    public override ModelsApiService.InvocationResult invokeChatGeneration(
      List<ModelsApiService.MessageInput> messages,
      String modelName
    ) {
      lastModelName = modelName;
      return buildResult();
    }

    private ModelsApiService.InvocationResult buildResult() {
      ModelsApiService.InvocationResult result = new ModelsApiService.InvocationResult();
      result.success = !shouldFail;
      result.text = nextText;
      result.generationId = nextGenerationId;
      result.errorCode = nextErrorCode;
      result.errorMessage = nextErrorMessage;
      return result;
    }
  }

  @isTest
  static void generateFromPromptReturnsTextOnSuccess() {
    ModelsApiService.invoker = new FakeModelsInvoker(false, 'Hello from the model.', 'gen-text-001', null, null);

    ModelsApiService.GenerationResult result = ModelsApiService.generateFromPrompt('Say hello.');

    System.assertEquals(true, result.success, 'Expected successful prompt generation.');
    System.assertEquals('Hello from the model.', result.text, 'Expected generated text to be returned.');
    System.assertEquals('gen-text-001', result.generationId, 'Expected generation id to be mapped.');
    System.assertEquals(
      'sfdc_ai__DefaultBedrockAnthropicClaude45Haiku',
      result.modelName,
      'Expected the centralized default model name.'
    );
  }

  @isTest
  static void generateFromMessagesReturnsFirstChatGenerationOnSuccess() {
    ModelsApiService.invoker = new FakeModelsInvoker(false, 'Structured lead draft.', 'chat-gen-001', null, null);

    ModelsApiService.GenerationResult result = ModelsApiService.generateFromMessages(
      new List<ModelsApiService.MessageInput>{
        new ModelsApiService.MessageInput('system', 'Use only the supplied evidence.'),
        new ModelsApiService.MessageInput('user', 'Draft a lead from the evidence packet.')
      }
    );

    System.assertEquals(true, result.success, 'Expected successful chat generation.');
    System.assertEquals('Structured lead draft.', result.text, 'Expected text from the fake chat response.');
    System.assertEquals('chat-gen-001', result.generationId, 'Expected chat generation id to be mapped.');
  }

  @isTest
  static void generateFromMessagesUsesChosenModelName() {
    ModelsApiService.invoker = new FakeModelsInvoker(false, 'Structured lead draft.', 'chat-gen-002', null, null);

    ModelsApiService.GenerationResult result = ModelsApiService.generateFromMessages(
      new List<ModelsApiService.MessageInput>{
        new ModelsApiService.MessageInput('system', 'Use only the supplied evidence.'),
        new ModelsApiService.MessageInput('user', 'Draft a lead from the evidence packet.')
      },
      'sfdc_ai__DefaultGPT41'
    );

    FakeModelsInvoker fakeInvoker = (FakeModelsInvoker) ModelsApiService.invoker;
    System.assertEquals('sfdc_ai__DefaultGPT41', fakeInvoker.lastModelName, 'Expected the selected model name to be forwarded.');
    System.assertEquals('sfdc_ai__DefaultGPT41', result.modelName, 'Expected the selected model name in the result.');
  }

  @isTest
  static void generateFromPromptRejectsBlankPrompt() {
    try {
      ModelsApiService.generateFromPrompt('   ');
      System.assert(false, 'Expected blank prompt validation to throw.');
    } catch (ModelsApiService.ModelsApiServiceException e) {
      System.assertEquals('Prompt text is required.', e.getMessage(), 'Expected deterministic validation failure.');
    }
  }

  @isTest
  static void generateFromMessagesRejectsEmptyMessages() {
    try {
      ModelsApiService.generateFromMessages(new List<ModelsApiService.MessageInput>());
      System.assert(false, 'Expected empty message validation to throw.');
    } catch (ModelsApiService.ModelsApiServiceException e) {
      System.assertEquals(
        'At least one chat message is required.',
        e.getMessage(),
        'Expected deterministic validation failure.'
      );
    }
  }

  @isTest
  static void generateFromMessagesRejectsBlankMessageContent() {
    try {
      ModelsApiService.generateFromMessages(
        new List<ModelsApiService.MessageInput>{
          new ModelsApiService.MessageInput('user', '   ')
        }
      );
      System.assert(false, 'Expected blank message content validation to throw.');
    } catch (ModelsApiService.ModelsApiServiceException e) {
      System.assertEquals(
        'Message content is required at index 0.',
        e.getMessage(),
        'Expected deterministic validation failure.'
      );
    }
  }

  @isTest
  static void providerFailureMapsToFailureResult() {
    ModelsApiService.invoker = new FakeModelsInvoker(
      true,
      null,
      null,
      'MODEL_RATE_LIMIT',
      'The provider asked the caller to retry later.'
    );

    ModelsApiService.GenerationResult result = ModelsApiService.generateFromPrompt('Generate a brief summary.');

    System.assertEquals(false, result.success, 'Expected provider failure to map to a non-throwing result.');
    System.assertEquals('MODEL_RATE_LIMIT', result.errorCode, 'Expected error code to be preserved.');
    System.assertEquals(
      'The provider asked the caller to retry later.',
      result.errorMessage,
      'Expected error message to be preserved.'
    );
  }
}
