import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

interface Message {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

interface LLMResponse {
  id: string;
  choices: {
    message: Message;
    finish_reason: string;
  }[];
}

@Injectable()
export class LLMService {
  private readonly apiKey: string;
  private readonly apiUrl = 'https://api.awanllm.com/v1/chat/completions';
  private receiptCache = new Map<string, any>();

  constructor(private configService: ConfigService) {
    this.apiKey = this.configService.get<string>('AWANLLM_API_KEY') || "";
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
      console.error('LLM API Error:', error);
      throw new Error('Failed to generate LLM response');
    }
  }

  private generateHash(text: string): string {
    const crypto = require('crypto');
    return crypto.createHash('md5').update(text).digest('hex');
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
          if cateogry is not found, return "Others", ONLY REQUESTED JSON, NO OTHER TEXT, NO EXPLANATION, NO COMMENTS ONLY JSON
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
      
      // Store in cache
      this.receiptCache.set(textHash, parsedResponse);
      
      console.log("🚀 ~ LLMService ~ analyzeReceipt ~ response:", response);
      return parsedResponse;
    } catch (error) {
      console.error('Receipt analysis error:', error);
      throw new Error('Failed to analyze receipt');
    }
  }
}