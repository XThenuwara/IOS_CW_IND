import { Module } from '@nestjs/common';
import { EventService } from './event.service';
import { EventController } from './event.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Event } from './entities/event.entity';
import { PurchasedTickets } from './entities/purchased-tickets.entity';
import { User } from '../user/entities/user.entity';
import { OutingModule } from '../outing/outing.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Event, PurchasedTickets, User]),
    OutingModule
  ],
  controllers: [EventController],
  providers: [EventService],
})
export class EventModule {}
