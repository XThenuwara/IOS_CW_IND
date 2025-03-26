import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule } from '@nestjs/config';
import { databaseConfig, databaseConfigModule } from './config/database.config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EventModule } from './event/event.module';
import { OutingModule } from './outing/outing.module';
import { UserModule } from './user/user.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      envFilePath: process.env.NODE_ENV ? `.env.${process.env.NODE_ENV}` : '.env',
      load: [databaseConfigModule],
      isGlobal: true,
      cache: true,
    }),
    TypeOrmModule.forRoot(databaseConfig),
    EventModule,
    OutingModule,
    UserModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
