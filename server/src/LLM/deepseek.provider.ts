import { Injectable } from '@nestjs/common';
import { LLMProvider, Message } from './llm-provider.interface';
import OpenAI from 'openai';

@Injectable()
export class DeepseekProvider implements LLMProvider {
    private readonly openai: OpenAI;

    constructor() {
        const apiKey = process.env.DEEPSEEK_API_KEY;
        if (!apiKey) {
            throw new Error('DEEPSEEK_API_KEY is not defined in environment variables');
        }

        this.openai = new OpenAI({
            baseURL: 'https://api.deepseek.com/v1',
            apiKey: apiKey
        });
    }

    async generateResponse(messages: Message[]): Promise<string> {
        try {
            const completion = await this.openai.chat.completions.create({
                model: 'deepseek-chat',
                messages: messages.map(msg => ({
                    role: msg.role,
                    content: msg.content
                })),
                temperature: 0.7,
                max_tokens: 4000
            });

            if (!completion.choices || completion.choices.length === 0) {
                throw new Error('No response received from Deepseek API');
            }

            const content = completion.choices[0]?.message?.content;
            if (!content) {
                throw new Error('Empty response from Deepseek API');
            }

            return content;
        } catch (error) {
            console.error('Deepseek API Error:', error);
            throw new Error(`Failed to generate Deepseek response: ${error.message}`);
        }
    }
}