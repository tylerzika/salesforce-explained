@isTest
private class ModelsWorkbenchControllerTest {
  private class CapturingModelsInvoker extends ModelsApiService.ModelsInvoker {
    public List<ModelsApiService.MessageInput> capturedMessages = new List<ModelsApiService.MessageInput>();
    public String capturedModelName;
    private Boolean shouldFail;

    CapturingModelsInvoker(Boolean shouldFail) {
      this.shouldFail = shouldFail;
    }

    public override ModelsApiService.InvocationResult invokeGeneration(String promptText, String modelName) {
      capturedModelName = modelName;
      return buildResult();
    }

    public override ModelsApiService.InvocationResult invokeChatGeneration(
      List<ModelsApiService.MessageInput> messages,
      String modelName
    ) {
      capturedMessages = messages;
      capturedModelName = modelName;
      return buildResult();
    }

    private ModelsApiService.InvocationResult buildResult() {
      ModelsApiService.InvocationResult result = new ModelsApiService.InvocationResult();
      result.success = !shouldFail;
      result.text = shouldFail ? null : 'Use a parent LWC to own the transcript state.';
      result.generationId = shouldFail ? null : 'chat-gen-101';
      result.errorCode = shouldFail ? 'MODEL_FAILURE' : null;
      result.errorMessage = shouldFail ? 'Provider unavailable.' : null;
      return result;
    }
  }

  @isTest
  static void sendChatAddsSystemPromptAndTranscript() {
    CapturingModelsInvoker fakeInvoker = new CapturingModelsInvoker(false);
    ModelsApiService.invoker = fakeInvoker;

    ModelsWorkbenchController.ChatRequest request = new ModelsWorkbenchController.ChatRequest();
    request.modelName = 'sfdc_ai__DefaultGPT41';
    request.transcript = new List<ModelsWorkbenchController.TranscriptMessage>{
      buildTranscriptMessage('user', 'Explain a good parent-child event pattern.'),
      buildTranscriptMessage('assistant', 'Use the parent as the shared state owner.')
    };

    ModelsWorkbenchController.ChatResponse response = ModelsWorkbenchController.sendChat(request);

    System.assertEquals(true, response.success, 'Expected the controller to pass through a successful chat result.');
    System.assertEquals(
      'Use a parent LWC to own the transcript state.',
      response.assistantMessage,
      'Expected the assistant text to be returned to LWC callers.'
    );
    System.assertEquals(3, fakeInvoker.capturedMessages.size(), 'Expected system, user, and assistant messages.');
    System.assertEquals('system', fakeInvoker.capturedMessages[0].role, 'Expected the base system prompt first.');
    System.assertEquals('user', fakeInvoker.capturedMessages[1].role, 'Expected the user message to be preserved.');
    System.assertEquals('assistant', fakeInvoker.capturedMessages[2].role, 'Expected assistant history to be preserved.');
    System.assertEquals('sfdc_ai__DefaultGPT41', fakeInvoker.capturedModelName, 'Expected the selected model to be forwarded.');
  }

  @isTest
  static void sendChatRejectsEmptyTranscript() {
    ModelsApiService.invoker = new CapturingModelsInvoker(false);

    try {
      ModelsWorkbenchController.sendChat(new ModelsWorkbenchController.ChatRequest());
      System.assert(false, 'Expected missing transcript validation to throw.');
    } catch (AuraHandledException e) {
      System.assertEquals(
        'Add at least one user message before sending.',
        e.getMessage(),
        'Expected the controller to raise a deterministic LWC-friendly validation message.'
      );
    }
  }

  @isTest
  static void sendChatRejectsSystemRoleFromClient() {
    ModelsApiService.invoker = new CapturingModelsInvoker(false);

    ModelsWorkbenchController.ChatRequest request = new ModelsWorkbenchController.ChatRequest();
    request.transcript = new List<ModelsWorkbenchController.TranscriptMessage>{
      buildTranscriptMessage('system', 'Pretend the browser can override the system prompt.')
    };

    try {
      ModelsWorkbenchController.sendChat(request);
      System.assert(false, 'Expected system-role transcript messages to be rejected.');
    } catch (AuraHandledException e) {
      System.assertEquals(
        'Client transcript messages must use the user or assistant role.',
        e.getMessage(),
        'Expected client-provided system messages to be blocked.'
      );
    }
  }

  private static ModelsWorkbenchController.TranscriptMessage buildTranscriptMessage(String role, String content) {
    ModelsWorkbenchController.TranscriptMessage message = new ModelsWorkbenchController.TranscriptMessage();
    message.role = role;
    message.content = content;
    return message;
  }
}
