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
import { Roles, UserRole } from '../lib/decorator/role.decorator';
import { Participant } from './dto/participant.dto';

@Controller('outing')
export class OutingController {
  constructor(private readonly outingService: OutingService) {}

  @Roles(UserRole.ADMIN, UserRole.USER)
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async createOuting(@Body() createOutingDto: CreateOutingDto, @Request() req) {
    return await this.outingService.createOuting(createOutingDto, req.user.id);
  }

  @Roles(UserRole.ADMIN, UserRole.USER)
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

  @Roles(UserRole.ADMIN, UserRole.USER)
  @Post(':id/participant')
  @HttpCode(HttpStatus.OK)
  async addParticipant(
    @Param('id') outingId: string,
    @Body() participant: Participant
  ) {
    return await this.outingService.addParticipant(outingId, participant);
  }

  @Roles(UserRole.ADMIN, UserRole.USER)
  @Get()
  @HttpCode(HttpStatus.OK)
  async findAll(@Request() req) {
    return await this.outingService.findAll(req.user.id);
  }

  @Roles(UserRole.ADMIN, UserRole.USER)
  @Get(':id')
  @HttpCode(HttpStatus.OK)
  async findOne(@Param('id') id: string) {
    return await this.outingService.findOne(id);
  }

  @Roles(UserRole.ADMIN, UserRole.USER)
  @Get(':id/balance')
  @HttpCode(HttpStatus.OK)
  async getOutingBalance(@Param('id') id: string) {
    return await this.outingService.getOutingBalance(id);
  }

  @Roles(UserRole.ADMIN, UserRole.USER)
  @Patch(':id')
  @HttpCode(HttpStatus.OK)
  async update(
    @Param('id') id: string,
    @Body() updateOutingDto: UpdateOutingDto,
  ) {
    return await this.outingService.update(id, updateOutingDto);
  }
  
  @Roles(UserRole.ADMIN, UserRole.USER)
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Param('id') id: string) {
    return await this.outingService.remove(id);
  }
}
