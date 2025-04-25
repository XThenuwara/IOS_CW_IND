import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { LLMProvider, Message } from './llm-provider.interface';
import OpenAI from 'openai';

@Injectable()
export class OpenRouterProvider implements LLMProvider {
  private readonly openai: OpenAI;

  constructor(private configService: ConfigService) {
    this.openai = new OpenAI({
      baseURL: 'https://openrouter.ai/api/v1',
      apiKey: this.configService.get<string>('OPENROUTER_API_KEY'),
    });
  }

  async generateResponse(messages: Message[]): Promise<string> {
    try {
      const completion = await this.openai.chat.completions.create({
        model: this.configService.get<string>('OPENROUTER_MODEL') || 'openai/gpt-4',
        messages,
      });
      console.log("🚀 ~ OpenRouterProvider ~ generateResponse ~ completion:", completion)

      return completion.choices[0]?.message?.content || 'No response generated';
    } catch (error) {
      console.error('OpenRouter API Error:', error);
      throw new Error('Failed to generate OpenRouter response');
    }
  }
}