import { Controller, Get, Post, Body, Patch, Param, Delete, HttpCode, HttpStatus } from '@nestjs/common';
import { EventService } from './event.service';
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';

@Controller('event')
export class EventController {
  constructor(private readonly eventService: EventService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() createEventDto: CreateEventDto) {
    return await this.eventService.create(createEventDto);
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  async findAll() {
    return await this.eventService.findAll();
  }

  @Get(':id')
  @HttpCode(HttpStatus.OK)
  async findOne(@Param('id') id: string) {
    return await this.eventService.findOne(id);
  }

  @Patch(':id')
  @HttpCode(HttpStatus.OK)
  async update(@Param('id') id: string, @Body() updateEventDto: UpdateEventDto) {
    return await this.eventService.update(id, updateEventDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Param('id') id: string) {
    return await this.eventService.remove(id);
  }
}
