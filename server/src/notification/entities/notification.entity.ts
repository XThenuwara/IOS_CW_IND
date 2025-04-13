import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';
import { NotificationType } from './notification-type.enum';

@Entity('notifications')
export class Notification {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column('uuid')
    user_id: string;

    @Column({
        type: 'enum',
        enum: NotificationType,
        default: NotificationType.ADDED_TO_OUTING
    })
    type: NotificationType;

    @Column()
    title: string;

    @Column()
    message: string;

    @Column()
    referenceId: string

    @CreateDateColumn()
    sent_at: Date;

    @Column({ type: 'timestamp', nullable: true })
    read_at: Date;
}