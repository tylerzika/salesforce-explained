import { LightningElement, api } from 'lwc';
import sendChat from '@salesforce/apex/ModelsWorkbenchController.sendChat';

const MODELS = [
  { label: 'Amazon Nova Lite', value: 'sfdc_ai__DefaultBedrockAmazonNovaLite', note: 'Salesforce Trust Boundary' },
  { label: 'Amazon Nova Pro', value: 'sfdc_ai__DefaultBedrockAmazonNovaPro', note: 'Salesforce Trust Boundary' },
  { label: 'Anthropic Claude Haiku 4.5', value: 'sfdc_ai__DefaultBedrockAnthropicClaude45Haiku', note: 'Salesforce Trust Boundary' },
  { label: 'Anthropic Claude Opus 4.5', value: 'sfdc_ai__DefaultBedrockAnthropicClaude45Opus', note: 'Salesforce Trust Boundary' },
  { label: 'Anthropic Claude Sonnet 4', value: 'sfdc_ai__DefaultBedrockAnthropicClaude4Sonnet', note: 'Salesforce Trust Boundary' },
  { label: 'Anthropic Claude Sonnet 4.5', value: 'sfdc_ai__DefaultBedrockAnthropicClaude45Sonnet', note: 'Salesforce Trust Boundary' },
  { label: 'OpenAI / Azure OpenAI GPT 4 Omni (GPT-4o)', value: 'sfdc_ai__DefaultGPT4Omni', note: 'Geo-aware' },
  { label: 'OpenAI / Azure OpenAI GPT 4 Omni Mini (GPT-4o mini)', value: 'sfdc_ai__DefaultGPT4OmniMini', note: 'Geo-aware' },
  { label: 'OpenAI GPT 4 Omni Mini (GPT-4o mini)', value: 'sfdc_ai__DefaultOpenAIGPT4OmniMini', note: null },
  { label: 'OpenAI / Azure OpenAI GPT 4.1', value: 'sfdc_ai__DefaultGPT41', note: 'Geo-aware' },
  { label: 'OpenAI / Azure OpenAI GPT 4.1 Mini', value: 'sfdc_ai__DefaultGPT41Mini', note: 'Geo-aware' },
  { label: 'OpenAI / Azure OpenAI GPT 5', value: 'sfdc_ai__DefaultGPT5', note: 'Geo-aware' },
  { label: 'OpenAI / Azure OpenAI GPT 5 Mini', value: 'sfdc_ai__DefaultGPT5Mini', note: 'Geo-aware' },
  { label: 'OpenAI / Azure OpenAI GPT 5.1 (Beta)', value: 'sfdc_ai__DefaultGPT51', note: 'Geo-aware' },
  { label: 'OpenAI / Azure OpenAI GPT 5.2 (Beta)', value: 'sfdc_ai__DefaultGPT52', note: 'Geo-aware' },
  { label: 'OpenAI / Azure OpenAI O3', value: 'sfdc_ai__DefaultO3', note: 'Geo-aware' },
  { label: 'OpenAI / Azure OpenAI O4 Mini', value: 'sfdc_ai__DefaultO4Mini', note: 'Geo-aware' },
  { label: 'Vertex AI Gemini 2.5 Flash', value: 'sfdc_ai__DefaultVertexAIGemini25Flash001', note: null },
  { label: 'Vertex AI Gemini 2.5 Flash Lite', value: 'sfdc_ai__DefaultVertexAIGemini25FlashLite001', note: null },
  { label: 'Vertex AI Gemini 2.5 Pro', value: 'sfdc_ai__DefaultVertexAIGeminiPro25', note: null },
  { label: 'Vertex AI Gemini 3 Flash', value: 'sfdc_ai__DefaultVertexAIGemini30Flash', note: null },
  { label: 'Vertex AI Gemini 3 Pro', value: 'sfdc_ai__DefaultVertexAIGeminiPro30', note: null }
];

export default class ModelsChatCard extends LightningElement {
  @api cardId;
  @api cardTitle;

  draftMessage = '';
  errorMessage;
  isLoading = false;
  messages = [];
  messageSequence = 1;
  selectedModel = 'sfdc_ai__DefaultBedrockAnthropicClaude45Haiku';

  get modelOptions() {
    return MODELS.map((model) => ({
      label: model.note ? `${model.label} - ${model.note}` : model.label,
      value: model.value
    }));
  }

  get hasMessages() {
    return this.messages.length > 0;
  }

  get visibleMessages() {
    return this.messages.map((message) => ({
      ...message,
      itemClass: `message message_${message.role}`,
      roleLabel: message.role === 'assistant' ? 'Assistant' : 'You',
      roleClass: `message__role message__role_${message.role}`
    }));
  }

  get isSendDisabled() {
    return this.isLoading || !this.draftMessage || !this.draftMessage.trim();
  }

  get selectedModelDetails() {
    return MODELS.find((model) => model.value === this.selectedModel);
  }

  get selectedModelLabel() {
    return this.selectedModelDetails ? this.selectedModelDetails.label : 'Unknown model';
  }

  get selectedModelNote() {
    return this.selectedModelDetails ? this.selectedModelDetails.note : null;
  }

  handleModelChange(event) {
    this.selectedModel = event.detail.value;
  }

  handleDraftChange(event) {
    this.draftMessage = event.target.value;
  }

  handleDeleteCard() {
    this.dispatchEvent(
      new CustomEvent('deletecard', {
        detail: { cardId: this.cardId }
      })
    );
  }

  handleKeydown(event) {
    if ((event.metaKey || event.ctrlKey) && event.key === 'Enter') {
      event.preventDefault();
      this.handleSend();
    }
  }

  async handleSend() {
    const prompt = (this.draftMessage || '').trim();
    if (!prompt || this.isLoading) {
      return;
    }

    const nextMessages = [...this.messages, this.createMessage('user', prompt)];
    this.messages = nextMessages;
    this.draftMessage = '';
    this.errorMessage = null;
    this.isLoading = true;

    try {
      const response = await sendChat({
        request: {
          modelName: this.selectedModel,
          transcript: nextMessages.map((message) => ({
            role: message.role,
            content: message.content
          }))
        }
      });

      if (!response.success) {
        this.errorMessage = this.buildResponseError(response);
        return;
      }

      const assistantText = (response.assistantMessage || '').trim() || 'The model returned an empty response.';
      this.messages = [
        ...nextMessages,
        this.createMessage('assistant', assistantText, this.buildMessageMeta(response))
      ];
    } catch (error) {
      this.errorMessage = this.reduceError(error);
    } finally {
      this.isLoading = false;
    }
  }

  createMessage(role, content, meta = '') {
    return {
      id: `${this.cardId}-message-${this.messageSequence++}`,
      role,
      content,
      meta
    };
  }

  buildMessageMeta(response) {
    const parts = [];
    if (response.modelName) {
      parts.push(response.modelName);
    }
    if (response.generationId) {
      parts.push(`id ${response.generationId}`);
    }
    return parts.join(' | ');
  }

  buildResponseError(response) {
    const code = response.errorCode ? `${response.errorCode}: ` : '';
    return `${code}${response.errorMessage || 'The Models API call failed.'}`;
  }

  reduceError(error) {
    if (error && error.body && error.body.message) {
      return error.body.message;
    }
    if (error && error.message) {
      return error.message;
    }
    return 'Unexpected error while calling Apex.';
  }
}
