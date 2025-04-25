import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule } from '@nestjs/config';
import { databaseConfig, databaseConfigModule } from './config/database.config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EventModule } from './event/event.module';
import { OutingModule } from './outing/outing.module';
import { UserModule } from './user/user.module';
import { AuthGuard } from './lib/guard/auth.guard';
import { APP_GUARD } from '@nestjs/core';
import { JwtModule } from '@nestjs/jwt';
import { AuthModule } from './auth/auth.module';
import { GroupModule } from './group/group.module';
import { LLMService } from './llm.service';
import { NotificationModule } from './notification/notification.module';
import { OpenRouterProvider } from './LLM/openrouter.provider';
import { AwanLLMProvider } from './LLM/awanllm.provider';
import { DeepseekProvider } from './LLM/deepseek.provider';
import { GeminiProvider } from './LLM/gemini.provider';


@Module({
  imports: [
    ConfigModule.forRoot({
      envFilePath: process.env.NODE_ENV
        ? `.env.${process.env.NODE_ENV}`
        : '.env',
      load: [databaseConfigModule],
      isGlobal: true,
      cache: true,
    }),
    JwtModule.register({
      global: true,
      secret: process.env.JWT_SECRET,
      signOptions: { expiresIn: '100d' },
    }),
    TypeOrmModule.forRoot(databaseConfig),
    EventModule,
    OutingModule,
    UserModule,
    AuthModule,
    GroupModule,
    NotificationModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_GUARD,
      useClass: AuthGuard,
    },
    OpenRouterProvider,
    AwanLLMProvider,
    DeepseekProvider,
    GeminiProvider,
    LLMService
  ],
})
export class AppModule {}
