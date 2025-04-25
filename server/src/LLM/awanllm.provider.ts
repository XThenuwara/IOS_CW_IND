import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { LLMProvider, Message } from './llm-provider.interface';

interface LLMResponse {
  id: string;
  choices: {
    message: Message;
    finish_reason: string;
  }[];
}

@Injectable()
export class AwanLLMProvider implements LLMProvider {
  private readonly apiKey: string;
  private readonly apiUrl = 'https://api.awanllm.com/v1/chat/completions';

  constructor(private configService: ConfigService) {
    this.apiKey = this.configService.get<string>('AWANLLM_API_KEY') || '';
  }

  async generateResponse(messages: Message[]): Promise<string> {
    try {
      const response = await fetch(this.apiUrl, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'Meta-Llama-3-8B-Instruct',
          messages,
          repetition_penalty: 1.1,
          temperature: 0.7,
          top_p: 0.9,
          top_k: 40,
          max_tokens: 1024,
          stream: false,
        }),
      });

      if (!response.ok) {
        throw new Error(`API request failed: ${response.statusText}`);
      }

      const data: LLMResponse = await response.json();
      return data.choices[0]?.message?.content || 'No response generated';
    } catch (error) {
      console.error('AwanLLM API Error:', error);
      throw new Error('Failed to generate AwanLLM response');
    }
  }
}