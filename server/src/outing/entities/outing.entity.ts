import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, ManyToMany, JoinTable, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { User } from '../../user/entities/user.entity';
import { Activity } from './actvity.entity';
import { OutingEvent } from './outing-event.entity';

@Entity()
export class Outing {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @ManyToOne(() => User)
    owner: User;

    @Column()
    title: string;

    @Column()
    description: string;
    
    @Column('text', { array: true, default: [] })
    participants: string[];

    @OneToMany(() => Activity, activity => activity.outing)
    activities: Activity[];

    @OneToMany(() => OutingEvent, outingEvent => outingEvent.outing)
    outingEvents: OutingEvent[];

    @Column({
        type: 'enum',
        enum: ['draft', 'in_progress', 'unsettled', 'settled'],
        default: 'draft'
    })
    status: string;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}



