import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '@/user/entities/user.entity';
import { Event } from './event.entity';

@Entity()
export class PurchasedTickets {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'userId' })
    user: User;

    @Column()
    userId: string;

    @ManyToOne(() => Event)
    @JoinColumn({ name: 'eventId' })
    event: Event;

    @Column()
    eventId: string;

    @Column()
    ticketType: string;

    @Column()
    quantity: number;

    @Column('decimal', { precision: 10, scale: 2 })
    unitPrice: number;

    @Column('decimal', { precision: 10, scale: 2 })
    totalAmount: number;

    @Column({ default: 'pending' })
    status: string;

    @Column({ nullable: true })
    paymentMethod: string;

    @Column({ nullable: true })
    paymentReference: string;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}