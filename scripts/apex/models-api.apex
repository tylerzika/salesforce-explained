// Keep this script as the smallest possible prompt-based smoke test. The
// richer chat-first example lives in models-api-lead-draft.apex.
ModelsApiService.GenerationResult result = ModelsApiService.generateFromPrompt(
  'What is a book you are trained on?'
);

if (result.success) {
  System.debug('Models API response: ' + result.text);
  System.debug('Generation id: ' + result.generationId);
} else {
  System.debug('Response error code: ' + result.errorCode);
  System.debug('Response error message: ' + result.errorMessage);
}
