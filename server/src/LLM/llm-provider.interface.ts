export interface Message {
    role: 'system' | 'user' | 'assistant';
    content: string;
  }
  
  export interface LLMProvider {
    generateResponse(messages: Message[]): Promise<string>;
  }