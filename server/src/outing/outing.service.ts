import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateOutingDto } from './dto/create-outing.dto';
import { UpdateOutingDto } from './dto/update-outing.dto';
import { CreateActivityDto } from './dto/create-activity.dto';
import { Outing } from './entities/outing.entity';
import { Activity } from './entities/actvity.entity';
import { User } from '../user/entities/user.entity';
import { Participant } from './dto/participant.dto';
import { Event } from '../event/entities/event.entity';
import { OutingEvent } from './entities/outing-event.entity';

@Injectable()
export class OutingService {
  private logger = new Logger(OutingService.name);
  constructor(
    @InjectRepository(Outing)
    private outingRepository: Repository<Outing>,
    @InjectRepository(Activity)
    private activityRepository: Repository<Activity>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Event)
    private eventRepository: Repository<Event>,
    @InjectRepository(OutingEvent)
    private outingEventRepository: Repository<OutingEvent>,
  ) {}

  async createOuting(createOutingDto: CreateOutingDto, userId: string): Promise<Outing> {
    this.logger.log(`Creating new outing for user: ${userId}`);
    try {
      const owner = await this.userRepository.findOne({ where: { id: userId } });
      if (!owner) {
        this.logger.error(`User not found: ${userId}`);
        throw new NotFoundException('User not found');
      }
      
      const outing = this.outingRepository.create({
        title: createOutingDto.title,
        description: createOutingDto.description,
        status: 'draft',
        owner,
        participants: Array.isArray(createOutingDto.participants) ? createOutingDto.participants : [],
      });
  
      const savedOuting = await this.outingRepository.save(outing);
  
      if (createOutingDto.eventId) {
        await this.createOutingEvent(savedOuting, createOutingDto.eventId);
      }
  
      this.logger.log(`Successfully created outing with ID: ${savedOuting.id}`);
      return this.findOne(savedOuting.id);
    } catch (error) {
      this.logger.error(`Failed to create outing: ${error.message}`);
      throw error;
    }
  }

  private async createOutingEvent(outing: Outing, eventId: string): Promise<void> {
    this.logger.log(`Creating outing event for outing: ${outing.id}, event: ${eventId}`);
    try {
      const event = await this.eventRepository.findOne({ 
        where: { id: eventId } 
      });
      
      if (!event) {
        throw new NotFoundException('Event not found');
      }
  
      const outingEvent = this.outingEventRepository.create({
        outing,
        event,
        tickets: []
      });
  
      await this.outingEventRepository.save(outingEvent);
    } catch (error) {
      this.logger.error(`Failed to create outing event: ${error.message}`);
      throw error;
    }
  }


  async addActivity(outingId: string, createActivityDto: CreateActivityDto, userId: string): Promise<Activity> {
    this.logger.log(`Adding activity to outing: ${outingId} by user: ${userId}`);
    try {
      const outing = await this.outingRepository.findOne({
        where: { id: outingId },
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
  
      this.logger.log(`Successfully added activity to outing: ${outingId}`);
      return await this.activityRepository.save(activity);
    } catch (error) {
      this.logger.error(`Failed to add activity: ${error.message}`);
      throw error;
    }
  }

  async findAll(userId: string): Promise<Outing[]> {
    this.logger.log(`Fetching all outings for user: ${userId}`);
    try {
      const outings = await this.outingRepository.find({
        where: [{ owner: { id: userId } }],
        relations: ['owner', 'activities', 'outingEvents'],
      });
      this.logger.log(`Found ${outings.length} outings for user: ${userId}`);
      return outings;
    } catch (error) {
      this.logger.error(`Failed to fetch outings: ${error.message}`);
      throw error;
    }
  }

  async findOne(id: string): Promise<Outing> {
    this.logger.log(`Fetching outing with ID: ${id}`);
    try {
      const outing = await this.outingRepository.findOne({
        where: { id },
        relations: ['owner', 'activities', 'outingEvents'],
      });
  
      if (!outing) {
        throw new NotFoundException(`Outing with ID ${id} not found`);
      }
  
      this.logger.log(`Successfully found outing: ${id}`);
      return outing;
    } catch (error) {
      this.logger.error(`Failed to fetch outing: ${error.message}`);
      throw error;
    }
  }

  async addParticipant(outingId: string, participant: Participant): Promise<Outing> {
    this.logger.log(`Adding participant to outing: ${outingId}`);
    try {
      const outing = await this.outingRepository.findOne({
        where: { id: outingId },
      });
  
      if (!outing) {
        throw new NotFoundException('Outing not found');
      }
  
      outing.participants = [...(outing.participants || []), participant.name];
      return await this.outingRepository.save(outing);
    } catch (error) {
      this.logger.error(`Failed to add participant: ${error.message}`);
      throw error;
    }
  }

  async update(id: string, updateOutingDto: UpdateOutingDto): Promise<Outing> {
    this.logger.log(`Updating outing: ${id}`);
    try {
      const outing = await this.findOne(id);
      Object.assign(outing, updateOutingDto);
      return await this.outingRepository.save(outing);
    } catch (error) {
      this.logger.error(`Failed to update outing: ${error.message}`);
      throw error;
    }
  }

  async remove(id: string): Promise<void> {
    this.logger.log(`Removing outing: ${id}`);
    try {
      const result = await this.outingRepository.delete(id);
      if (result.affected === 0) {
        throw new NotFoundException(`Outing with ID ${id} not found`);
      }
    } catch (error) {
      this.logger.error(`Failed to remove outing: ${error.message}`);
      throw error;
    }
  }

  async getOutingBalance(outingId: string): Promise<{ total: number; perPerson: number }> {
    this.logger.log(`Calculating balance for outing: ${outingId}`);
    try {
      const outing = await this.outingRepository.findOne({
        where: { id: outingId },
        relations: ['activities'],
      });
  
      if (!outing) {
        throw new NotFoundException('Outing not found');
      }
  
      const total = outing.activities.reduce((sum, activity) => sum + Number(activity.amount), 0);
      const perPerson = total / (outing.participants?.length || 1);
  
      this.logger.log(`Successfully calculated balance for outing: ${outingId}`);
      return { total, perPerson };
    } catch (error) {
      this.logger.error(`Failed to calculate balance: ${error.message}`);
      throw error;
    }
  }
}
