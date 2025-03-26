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

    @ManyToMany(() => User)
    @JoinTable()
    participants: User[];

    @OneToMany(() => Activity, activity => activity.outing)
    activities: Activity[];

    @OneToMany(() => OutingEvent, outingEvent => outingEvent.outing)
    outingEvents: OutingEvent[];

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}



