import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { Outing } from './outing.entity';
import { Event } from '../../event/entities/event.entity';

class Ticket {
    @Column()
    title: string;

    @Column()
    link: string;

    @Column('decimal', { precision: 10, scale: 2 })
    price: number;

    @Column()
    quantity: number;

    @Column()
    type: string;
}

@Entity()
export class OutingEvent {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @ManyToOne(() => Outing, outing => outing.outingEvents)
    outing: Outing;

    @ManyToOne(() => Event)
    event: Event;

    @Column('json')
    tickets: Ticket[];

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}

