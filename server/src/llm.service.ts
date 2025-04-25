import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Message, LLMProvider } from './LLM/llm-provider.interface';
import { OpenRouterProvider } from './LLM/openrouter.provider';
import { AwanLLMProvider } from './LLM/awanllm.provider';
import { DeepseekProvider } from './LLM/deepseek.provider';
import { GeminiProvider } from './LLM/gemini.provider';

@Injectable()
export class LLMService {
  private provider: LLMProvider;
  private receiptCache = new Map<string, any>();

  constructor(
    private configService: ConfigService,
    private openRouterProvider: OpenRouterProvider,
    private awanLLMProvider: AwanLLMProvider,
    private deepseekProvider: DeepseekProvider,
    private geminiProvider: GeminiProvider
  ) {
    // Choose provider based on configuration
    const useOpenRouter = this.configService.get<boolean>('USE_OPENROUTER') || false;
    console.log('Use OpenRouter:', useOpenRouter);
    this.provider = useOpenRouter ? geminiProvider : geminiProvider;
  }

  private generateHash(text: string): string {
    const crypto = require('crypto');
    return crypto.createHash('md5').update(text).digest('hex');
  }

  async generateResponse(messages: Message[]): Promise<string> {
    return this.provider.generateResponse(messages);
  }

  async analyzeReceipt(receiptText: string): Promise<any> {
    const textHash = this.generateHash(receiptText);
    
    if (this.receiptCache.has(textHash)) {
      console.log('Cache hit for receipt analysis');
      return this.receiptCache.get(textHash);
    }

    const messages: Message[] = [
      {
        role: 'system',
        content: `You are a receipt analysis assistant. Extract the total amount, date, and merchant name, category from the receipt text. response should be like 
        {
          "totalAmount": 123.45,
          "date": "2023-10-10",
          "merchantName": "Example Merchant",
          "category": "Food"
        }
          if cateogry is not found, return "Others", ONLY REQUESTED JSON, NO OTHER TEXT,NO MARKDOWN SYNTAX, NO EXPLANATION, NO COMMENTS ONLY JSON
        `
      },
      {
        role: 'user',
        content: `Please analyze this receipt text and return the information in JSON format: ${receiptText}`,
      },
    ];

    try {
      const response = await this.generateResponse(messages);
      const parsedResponse = JSON.parse(response);
      
      this.receiptCache.set(textHash, parsedResponse);
      
      return parsedResponse;
    } catch (error) {
      console.error('Receipt analysis error:', error);
      throw new Error('Failed to analyze receipt');
    }
  }
}