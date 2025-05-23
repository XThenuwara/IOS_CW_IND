import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request, HttpCode, HttpStatus, UseInterceptors, UploadedFile } from '@nestjs/common';
import { OutingService } from './outing.service';
import { CreateOutingDto } from './dto/create-outing.dto';
import { UpdateOutingDto } from './dto/update-outing.dto';
import { CreateActivityDto } from './dto/create-activity.dto';
import { Roles, UserRole } from '../lib/decorator/role.decorator';
import { Participant } from './dto/participant.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import { Express } from 'express';

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
  @Post('/activity')
  @HttpCode(HttpStatus.CREATED)
  async addActivity(@Body() createActivityDto: CreateActivityDto, @Request() req) {
    return await this.outingService.addActivity(createActivityDto, req.user.id);
  }

  @Roles(UserRole.ADMIN, UserRole.USER)
  @Post(':id/participant')
  @HttpCode(HttpStatus.OK)
  async addParticipant(@Param('id') outingId: string, @Body() participant: Participant) {
    return await this.outingService.addParticipant(outingId, participant);
  }

  @Roles(UserRole.ADMIN, UserRole.USER)
  @Patch(':id/participants')
  @HttpCode(HttpStatus.OK)
  async updateParticipants(@Param('id') outingId: string, @Body() participants: Participant[], @Request() req) {
    return await this.outingService.updateParticipants(outingId, participants, req.user.id);
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
  async update(@Param('id') id: string, @Body() updateOutingDto: UpdateOutingDto) {
    return await this.outingService.update(id, updateOutingDto);
  }

  @Roles(UserRole.ADMIN, UserRole.USER)
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Param('id') id: string) {
    return await this.outingService.remove(id);
  }

  @Roles(UserRole.ADMIN, UserRole.USER)
  @Post('activity/:id/image')
  @UseInterceptors(FileInterceptor('image'))
  @HttpCode(HttpStatus.OK)
  async uploadActivityImage(@Param('id') activityId: string, @UploadedFile() file: Express.Multer.File, @Request() req) {
    return await this.outingService.uploadActivityImage(activityId, file, req.user.id);
  }

  @Roles(UserRole.ADMIN, UserRole.USER)
  @Get('activity/:id/images')
  @HttpCode(HttpStatus.OK)
  async getActivityImages(@Param('id') activityId: string) {
    return await this.outingService.getImagesForActivity(activityId);
  }

  @Roles(UserRole.ADMIN, UserRole.USER)
  @Patch('debt/:id/status')
  @HttpCode(HttpStatus.OK)
  async updateDebtStatus(@Param('id') debtId: string, @Body('status') status: 'pending' | 'paid') {
    return await this.outingService.updateDebtStatus(debtId, status);
  }
}
