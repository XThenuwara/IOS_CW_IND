import { Controller, Get, Post, Body, Patch, Param } from '@nestjs/common';
import { NotificationService } from './notification.service';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { UpdateNotificationDto } from './dto/update-notification.dto';
import { Roles, UserRole } from '../lib/decorator/role.decorator';

@Controller('notification')
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  @Roles(UserRole.USER)
  @Post()
  create(@Body() createNotificationDto: CreateNotificationDto) {
    return this.notificationService.create(createNotificationDto);
  }

  @Roles(UserRole.USER)
  @Get('unread/:userId')
  getUnreadByUserId(@Param('userId') userId: string) {
    return this.notificationService.getUnreadByUserId(userId);
  }

  @Roles(UserRole.USER)
  @Patch(':id')
  update(@Param('id') id: string, @Body() updateNotificationDto: UpdateNotificationDto) {
    return this.notificationService.update(id, updateNotificationDto);
  }

  @Roles(UserRole.USER)
  @Patch(':id/read')
  markAsRead(@Param('id') id: string) {
    return this.notificationService.markAsRead(id);
  }
}
