import { Injectable } from '@nestjs/common';
import { LLMProvider, Message } from './llm-provider.interface';
import { GoogleGenAI } from '@google/genai';

@Injectable()
export class GeminiProvider implements LLMProvider {
    private readonly genAI: GoogleGenAI;

    constructor() {
        const apiKey = process.env.GEMINI_API_KEY;
        if (!apiKey) {
            throw new Error('GEMINI_API_KEY is not defined in environment variables');
        }
        this.genAI = new GoogleGenAI({ apiKey });
    }

    async generateResponse(messages: Message[]): Promise<string> {
        try {
            const content = messages.map(msg => {
                if (msg.role === 'system') {
                    return `System: ${msg.content}\n`;
                } else if (msg.role === 'user') {
                    return `User: ${msg.content}\n`;
                } else {
                    return `Assistant: ${msg.content}\n`;
                }
            }).join('');

            const response = await this.genAI.models.generateContent({
                model: 'gemini-1.5-flash',
                contents: content,
            });
            const responseParsed = response?.candidates?.[0].content?.parts?.[0].text?.replace(/```json|```/g, '').trim();
            console.log("🚀 ~ GeminiProvider ~ generateResponse ~ response:", responseParsed);

            return responseParsed?.toString() || '';
        } catch (error) {
            console.error('Gemini API Error:', error);
            throw new Error(`Failed to generate Gemini response: ${error.message}`);
        }
    }
}