import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, ManyToMany, JoinTable, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { User } from '../../user/entities/user.entity';
import { Outing } from './outing.entity';

@Entity()
export class Activity {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    paidById: string;

    @Column('decimal', { precision: 10, scale: 2 })
    amount: number;

    @Column()
    title: string;

    @Column({ nullable: true })
    description: string;
        
    @Column({ nullable: true })
    category: string;

    @Column('simple-array', { nullable: true })
    participants: string[]

    @ManyToOne(() => Outing, outing => outing.activities)
    outing: Outing;

    @Column('simple-array', { nullable: true })
    references: string[];

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}