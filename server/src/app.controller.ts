import { Controller, Get, Post, Body } from '@nestjs/common';
import { AppService } from './app.service';
import { LLMService } from './llm.service';
import { Roles, UserRole } from './lib/decorator/role.decorator';

@Controller()
export class AppController {
  constructor(
    private readonly appService: AppService,
    private readonly llmService: LLMService,
  ) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @Roles(UserRole.USER)
  @Post('analyze-receipt')
  async analyzeReceipt(@Body() body: { receiptText: string }) {
    try {
      const analysis = await this.llmService.analyzeReceipt(body.receiptText);
      return {
        success: true,
        data: analysis,
      };
    } catch (error) {
      return {
        success: false,
        error: error.message,
      };
    }
  }
}
