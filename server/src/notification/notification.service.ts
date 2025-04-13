import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsNull, Repository } from 'typeorm';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { UpdateNotificationDto } from './dto/update-notification.dto';
import { Notification } from './entities/notification.entity';

@Injectable()
export class NotificationService {
  constructor(
    @InjectRepository(Notification)
    private notificationRepository: Repository<Notification>,
  ) {}

  async create(createNotificationDto: CreateNotificationDto): Promise<Notification> {
    const notification = this.notificationRepository.create(createNotificationDto);
    return await this.notificationRepository.save(notification);
  }

  async update(id: string, updateNotificationDto: UpdateNotificationDto): Promise<Notification> {
    await this.notificationRepository.update(id, updateNotificationDto);
    const notification = await this.notificationRepository.findOne({ where: { id } });
    if (!notification) {
      throw new Error('Notification not found');
    }
    return notification;
  }

  async getUnreadByUserId(userId: string): Promise<Notification[]> {
    return this.notificationRepository.find({
      where: {
        user_id: userId,
        read_at: IsNull()
      },
      order: {
        sent_at: 'DESC'
      }
    });
  }

  async markAsRead(id: string): Promise<Notification> {
    await this.notificationRepository.update(id, {
      read_at: new Date()
    });
    const notification = await this.notificationRepository.findOne({ where: { id } });
    if (!notification) {
      throw new Error('Notification not found');
    }
    return notification;
  }
}
