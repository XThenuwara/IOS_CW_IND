import { IsNotEmpty, IsString, IsUUID, IsEnum } from 'class-validator';
import { NotificationType } from '../entities/notification-type.enum';

export class CreateNotificationDto {
    @IsUUID()
    @IsNotEmpty()
    user_id: string;

    @IsEnum(NotificationType)
    @IsNotEmpty()
    type: NotificationType;

    @IsString()
    @IsNotEmpty()
    title: string;

    @IsString()
    @IsNotEmpty()
    message: string;
}