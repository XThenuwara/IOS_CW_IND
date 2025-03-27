import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { EventTypeEnum } from '@/event/enum/event.enum';

@Entity()
export class Event {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    title: string;

    @Column()
    description: string;

    @Column({
        type: 'enum',
        enum: EventTypeEnum,
        default: EventTypeEnum.MUSICAL
    })
    eventType: EventTypeEnum;

    @Column()
    locationName: string;

    @Column()
    locationAddress: string;

    @Column()
    locationLongitudeLatitude: string;

    @Column({ type: 'timestamp' })
    eventDate: Date;

    @Column()
    organizerName: string;

    @Column()
    organizerPhone: string;

    @Column()
    organizerEmail: string;

    // Amenities
    @Column('simple-array')
    amenities: string[];

    // Requirements
    @Column('simple-array')
    requirements: string[];

    // Weather
    @Column()
    weatherCondition: string;

    // Capacity
    @Column()
    capacity: number;

    @Column({ default: 0 })
    sold: number;

    @Column('json')
    ticketTypes: {
        name: string;
        price: number;
        totalQuantity: number;
        soldQuantity: number;
    }[];

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}