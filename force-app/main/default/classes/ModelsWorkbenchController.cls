public with sharing class ModelsWorkbenchController {
  private static final String DEFAULT_SYSTEM_PROMPT = 'You like to exchange information with other LLMs.';

  public class TranscriptMessage {
    @AuraEnabled
    public String role { get; set; }

    @AuraEnabled
    public String content { get; set; }
  }

  public class ChatRequest {
    @AuraEnabled
    public List<TranscriptMessage> transcript { get; set; }

    @AuraEnabled
    public String modelName { get; set; }
  }

  public class ChatResponse {
    @AuraEnabled
    public Boolean success { get; set; }

    @AuraEnabled
    public String assistantMessage { get; set; }

    @AuraEnabled
    public String generationId { get; set; }

    @AuraEnabled
    public String modelName { get; set; }

    @AuraEnabled
    public String errorCode { get; set; }

    @AuraEnabled
    public String errorMessage { get; set; }
  }

  @AuraEnabled
  public static ChatResponse sendChat(ChatRequest request) {
    if (request == null) {
      throwHandled('Request payload is required.');
    }

    List<ModelsApiService.MessageInput> messages = new List<ModelsApiService.MessageInput>{
      new ModelsApiService.MessageInput('system', DEFAULT_SYSTEM_PROMPT)
    };

    List<TranscriptMessage> transcript = request.transcript == null
      ? new List<TranscriptMessage>()
      : request.transcript;

    if (transcript.isEmpty()) {
      throwHandled('Add at least one user message before sending.');
    }

    for (Integer messageIndex = 0; messageIndex < transcript.size(); messageIndex++) {
      TranscriptMessage message = transcript[messageIndex];
      if (message == null) {
        throwHandled('Transcript message at index ' + messageIndex + ' is required.');
      }

      String normalizedRole = normalizeRole(message.role);
      if (normalizedRole != 'user' && normalizedRole != 'assistant') {
        throwHandled('Client transcript messages must use the user or assistant role.');
      }

      if (String.isBlank(message.content)) {
        throwHandled('Transcript message content is required at index ' + messageIndex + '.');
      }

      messages.add(new ModelsApiService.MessageInput(normalizedRole, message.content.trim()));
    }

    ModelsApiService.GenerationResult result = ModelsApiService.generateFromMessages(messages, request.modelName);

    ChatResponse response = new ChatResponse();
    response.success = result.success;
    response.assistantMessage = result.text;
    response.generationId = result.generationId;
    response.modelName = result.modelName;
    response.errorCode = result.errorCode;
    response.errorMessage = result.errorMessage;
    return response;
  }

  private static String normalizeRole(String role) {
    return role == null ? null : role.trim().toLowerCase();
  }

  private static void throwHandled(String message) {
    AuraHandledException handledException = new AuraHandledException(message);
    handledException.setMessage(message);
    throw handledException;
  }
}
