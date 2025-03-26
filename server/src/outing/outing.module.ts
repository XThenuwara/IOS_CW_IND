import { Module } from '@nestjs/common';
import { OutingService } from './outing.service';
import { OutingController } from './outing.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Outing } from './entities/outing.entity';
import { OutingEvent } from './entities/outing-event.entity';
import { Activity } from './entities/actvity.entity';
import { UserModule } from '../user/user.module';
import { User } from '../user/entities/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Outing, OutingEvent, Activity, User]), UserModule],
  controllers: [OutingController],
  providers: [OutingService],
})
export class OutingModule {}
