import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { OutingService } from './outing.service';
import { CreateOutingDto } from './dto/create-outing.dto';
import { UpdateOutingDto } from './dto/update-outing.dto';
import { CreateActivityDto } from './dto/create-activity.dto';

@Controller('outing')
export class OutingController {
  constructor(private readonly outingService: OutingService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async createOuting(@Body() createOutingDto: CreateOutingDto, @Request() req) {
    return await this.outingService.createOuting(createOutingDto, req.user.id);
  }

  @Post(':id/activity')
  @HttpCode(HttpStatus.CREATED)
  async addActivity(
    @Param('id') outingId: string,
    @Body() createActivityDto: CreateActivityDto,
    @Request() req,
  ) {
    return await this.outingService.addActivity(
      outingId,
      createActivityDto,
      req.user.id,
    );
  }

  @Post(':id/participant/:participantId')
  @HttpCode(HttpStatus.OK)
  async addParticipant(
    @Param('id') outingId: string,
    @Param('participantId') participantId: string,
  ) {
    return await this.outingService.addParticipant(outingId, participantId);
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  async findAll(@Request() req) {
    return await this.outingService.findAll(req.user.id);
  }

  @Get(':id')
  @HttpCode(HttpStatus.OK)
  async findOne(@Param('id') id: string) {
    return await this.outingService.findOne(id);
  }

  @Get(':id/balance')
  @HttpCode(HttpStatus.OK)
  async getOutingBalance(@Param('id') id: string) {
    return await this.outingService.getOutingBalance(id);
  }

  @Patch(':id')
  @HttpCode(HttpStatus.OK)
  async update(
    @Param('id') id: string,
    @Body() updateOutingDto: UpdateOutingDto,
  ) {
    return await this.outingService.update(id, updateOutingDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Param('id') id: string) {
    return await this.outingService.remove(id);
  }
}
