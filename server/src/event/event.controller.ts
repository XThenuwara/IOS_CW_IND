import { Controller, Get, Post, Body, Patch, Param, Delete, HttpCode, HttpStatus, Request } from '@nestjs/common';
import { EventService } from './event.service';
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';
import { Roles, UserRole } from '../lib/decorator/role.decorator';
import { PurchaseTicketsDto } from './dto/purchase-tickets.dto';

@Controller('event')
export class EventController {
  constructor(private readonly eventService: EventService) {}

  @Roles(UserRole.ADMIN)
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() createEventDto: CreateEventDto) {
    return await this.eventService.create(createEventDto);
  }

  @Roles(UserRole.ADMIN, UserRole.USER)
  @Get()
  @HttpCode(HttpStatus.OK)
  async findAll() {
    return await this.eventService.findAll();
  }

  @Roles(UserRole.ADMIN, UserRole.USER)
  @Get(':id')
  @HttpCode(HttpStatus.OK)
  async findOne(@Param('id') id: string) {
    return await this.eventService.findOne(id);
  }

  @Roles(UserRole.ADMIN)
  @Patch(':id')
  @HttpCode(HttpStatus.OK)
  async update(@Param('id') id: string, @Body() updateEventDto: UpdateEventDto) {
    return await this.eventService.update(id, updateEventDto);
  }

  @Roles(UserRole.ADMIN)
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Param('id') id: string) {
    return await this.eventService.remove(id);
  }

  @Roles(UserRole.USER)
  @Post(':id/purchase')
  @HttpCode(HttpStatus.CREATED)
  async purchaseTickets(@Param('id') eventId: string, @Body() purchaseDto: PurchaseTicketsDto, @Request() req) {
    purchaseDto.eventId = eventId;
    return await this.eventService.purchaseTickets(req.user.id, purchaseDto);
  }

  @Roles(UserRole.USER)
  @Get(':id/purchased-tickets')
  @HttpCode(HttpStatus.OK)
  async getPurchasedTickets(@Param('id') eventId: string, @Request() req) {
    return await this.eventService.getPurchasedTickets(req.user.id, eventId);
  }

  @Roles(UserRole.USER)
  @Get('purchased-tickets/all')
  @HttpCode(HttpStatus.OK)
  async getAllPurchasedTickets(@Request() req) {
    return await this.eventService.getPurchasedTicketsForUser(req.user.id);
  }
}
