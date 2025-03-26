import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateOutingDto } from './dto/create-outing.dto';
import { UpdateOutingDto } from './dto/update-outing.dto';
import { CreateActivityDto } from './dto/create-activity.dto';
import { Outing } from './entities/outing.entity';
import { Activity } from './entities/actvity.entity';
import { User } from '../user/entities/user.entity';

@Injectable()
export class OutingService {
  constructor(
    @InjectRepository(Outing)
    private outingRepository: Repository<Outing>,
    @InjectRepository(Activity)
    private activityRepository: Repository<Activity>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  async createOuting(createOutingDto: CreateOutingDto, userId: string): Promise<Outing> {
    const owner = await this.userRepository.findOne({ where: { id: userId } });
    if (!owner) {
      throw new NotFoundException('User not found');
    }

    const outing = this.outingRepository.create({
      ...createOutingDto,
      owner,
      participants: [owner], 
    });

    return await this.outingRepository.save(outing);
  }

  async addActivity(outingId: string, createActivityDto: CreateActivityDto, userId: string): Promise<Activity> {
    const outing = await this.outingRepository.findOne({
      where: { id: outingId },
      relations: ['participants'],
    });

    if (!outing) {
      throw new NotFoundException('Outing not found');
    }

    const paidBy = await this.userRepository.findOne({ where: { id: userId } });
    if (!paidBy) {
      throw new NotFoundException('User not found');
    }

    const activity = this.activityRepository.create({
      ...createActivityDto,
      paidBy,
      outing,
    });

    return await this.activityRepository.save(activity);
  }

  async findAll(userId: string): Promise<Outing[]> {
    return await this.outingRepository.find({
      where: [
        { owner: { id: userId } },
        { participants: { id: userId } }
      ],
      relations: ['owner', 'participants', 'activities', 'outingEvents'],
    });
  }

  async findOne(id: string): Promise<Outing> {
    const outing = await this.outingRepository.findOne({
      where: { id },
      relations: ['owner', 'participants', 'activities', 'outingEvents'],
    });

    if (!outing) {
      throw new NotFoundException(`Outing with ID ${id} not found`);
    }

    return outing;
  }

  async addParticipant(outingId: string, participantId: string): Promise<Outing> {
    const outing = await this.outingRepository.findOne({
      where: { id: outingId },
      relations: ['participants'],
    });

    if (!outing) {
      throw new NotFoundException('Outing not found');
    }

    const participant = await this.userRepository.findOne({ where: { id: participantId } });
    if (!participant) {
      throw new NotFoundException('User not found');
    }

    outing.participants = [...outing.participants, participant];
    return await this.outingRepository.save(outing);
  }

  async update(id: string, updateOutingDto: UpdateOutingDto): Promise<Outing> {
    const outing = await this.findOne(id);
    Object.assign(outing, updateOutingDto);
    return await this.outingRepository.save(outing);
  }

  async remove(id: string): Promise<void> {
    const result = await this.outingRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Outing with ID ${id} not found`);
    }
  }

  async getOutingBalance(outingId: string): Promise<{ total: number; perPerson: number }> {
    const outing = await this.outingRepository.findOne({
      where: { id: outingId },
      relations: ['activities', 'participants'],
    });

    if (!outing) {
      throw new NotFoundException('Outing not found');
    }

    const total = outing.activities.reduce((sum, activity) => sum + Number(activity.amount), 0);
    const perPerson = total / outing.participants.length;

    return { total, perPerson };
  }
}
