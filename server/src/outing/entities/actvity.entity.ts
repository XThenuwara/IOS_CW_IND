import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, ManyToMany, JoinTable, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { User } from '../../user/entities/user.entity';
import { Outing } from './outing.entity';

@Entity()
export class Activity {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @ManyToOne(() => User)
    paidBy: User;

    @Column('decimal', { precision: 10, scale: 2 })
    amount: number;

    @Column()
    title: string;

    @Column()
    description: string;
        
    @Column()
    category: string;

    @ManyToMany(() => User)
    @JoinTable()
    participants: User[];

    @ManyToOne(() => Outing, outing => outing.activities)
    outing: Outing;

    @Column('simple-array')
    references: string[];

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}