import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, CreateDateColumn } from 'typeorm';
import { Outing } from './outing.entity';
@Entity()
export class Debt {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    fromUserId: String;

    @Column()
    toUserId: String;

    @Column('decimal', { precision: 10, scale: 2 })
    amount: number;

    @Column({
        type: 'enum',
        enum: ['pending', 'paid'],
        default: 'pending'
    })
    status: string;

    @ManyToOne(() => Outing, outing => outing.debts)
    outing: Outing;

    @CreateDateColumn()
    createdAt: Date;
}