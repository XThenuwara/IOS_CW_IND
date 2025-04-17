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
import { Debt } from './entities/debt.entity';
import { promises as fs } from 'fs';
import * as path from 'path';
import { v4 as uuidv4 } from 'uuid';

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
    @InjectRepository(Debt)
    private debtRepository: Repository<Debt>,
  ) {}

  async createOuting(createOutingDto: CreateOutingDto, userId: string): Promise<Outing> {
    this.logger.log(`Creating new outing for user: ${userId}`);
    try {
      const owner = await this.userRepository.findOne({
        where: { id: userId },
      });
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
        where: { id: eventId },
      });

      if (!event) {
        throw new NotFoundException('Event not found');
      }

      const outingEvent = this.outingEventRepository.create({
        outing,
        event,
        tickets: [],
      });

      await this.outingEventRepository.save(outingEvent);
    } catch (error) {
      this.logger.error(`Failed to create outing event: ${error.message}`);
      throw error;
    }
  }

  async addActivity(createActivityDto: CreateActivityDto, userId: string): Promise<Activity> {
    const { outingId, participantIds } = createActivityDto;
    this.logger.log(`Adding activity to outing: ${outingId.toLowerCase()} by user: ${userId}`);
    try {
      const outing = await this.outingRepository.findOne({
        where: { id: outingId.toLowerCase() },
        relations: ['owner', 'activities'],
      });

      if (!outing) {
        throw new NotFoundException('Outing not found');
      }
      const activity = this.activityRepository.create({
        ...createActivityDto,
        paidById: createActivityDto.paidById.toLowerCase(),
        outing: outing,
        participants: participantIds.map((id) => id.toLowerCase()),
      });

      const savedActivity = await this.activityRepository.save(activity);

      await this.calculateDebts(outing, userId);
      this.logger.log(`Successfully added activity to outing: ${outingId}`);
      return savedActivity;
    } catch (error) {
      this.logger.error(`Failed to add activity: ${error.message}`);
      throw error;
    }
  }

  private async calculateDebts(outing: Outing, userId: string): Promise<void> {
    this.logger.log(`Calculating debts for outing: ${outing.id}`);
    try {
      const freshOuting = await this.outingRepository.findOne({
        where: { id: outing.id.toLowerCase() },
        relations: ['activities'],
      });

      if (!freshOuting) {
        throw new NotFoundException('Outing not found');
      }

      const participants = [
        ...freshOuting.participants
          .map((participantStr) => {
            try {
              const participant = JSON.parse(participantStr);
              return participant.id.toLowerCase();
            } catch (e) {
              return null;
            }
          })
          .filter((id) => id !== null),
        userId.toLowerCase(),
      ];

      const balances: { [key: string]: number } = {};

      // Calculate initial balances
      for (const participantId of participants) {
        const paidActivities = freshOuting.activities.filter((a) => a.paidById.toLowerCase() === participantId);

        const paidAmount = paidActivities.reduce((sum, a) => sum + Number(a.amount), 0);

        const participatingActivities = freshOuting.activities.filter((a) => a.participants.includes(participantId));

        const owedAmount = participatingActivities.reduce((sum, a) => sum + Number(a.amount) / a.participants.length, 0);

        balances[participantId] = paidAmount - owedAmount;
      }

      // Delete existing debts
      await this.debtRepository.delete({ outing: { id: outing.id } });
      const debtors = Object.entries(balances).filter(([_, balance]) => balance < 0);
      const creditors = Object.entries(balances).filter(([_, balance]) => balance > 0);

      // Create debts
      while (debtors.length > 0 && creditors.length > 0) {
        const [debtorId, debtorBalance] = debtors[0];
        const [creditorId, creditorBalance] = creditors[0];

        const amount = Math.min(Math.abs(debtorBalance), creditorBalance);

        const debt = this.debtRepository.create({
          fromUserId: debtorId,
          toUserId: creditorId,
          amount: amount,
          outing: outing,
          status: 'pending',
        });
        await this.debtRepository.save(debt);

        // Update balances
        debtors[0][1] += amount;
        creditors[0][1] -= amount;

        if (debtors[0][1] === 0) debtors.shift();
        if (creditors[0][1] === 0) creditors.shift();
      }
    } catch (error) {
      this.logger.error(`Failed to calculate debts: ${error.message}`);
      this.logger.error(error.stack);
      throw error;
    }
  }

  async findAll(userId: string): Promise<Outing[]> {
    this.logger.log(`Fetching all outings for user: ${userId}`);
    try {
      const outings = await this.outingRepository.find({
        where: [{ owner: { id: userId } }],
        relations: ['owner', 'activities', 'outingEvents', 'outingEvents.event', 'debts'],
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

  async uploadActivityImage(activityId: string, file: Express.Multer.File, userId: string): Promise<Activity> {
    this.logger.log(`Uploading image for activity: ${activityId}`);
    try {
      const activity = await this.activityRepository.findOne({
        where: { id: activityId },
        relations: ['outing'],
      });

      if (!activity) {
        throw new NotFoundException('Activity not found');
      }


      const uploadsDir = path.join(process.cwd(), 'uploads');
      await fs.mkdir(uploadsDir, { recursive: true });

      const fileExtension = path.extname(file.originalname);
      const fileName = `${uuidv4()}${fileExtension}`;
      const filePath = path.join(uploadsDir, fileName);

      // Save file
      await fs.writeFile(filePath, file.buffer);

      activity.references = [`/uploads/${fileName}`];
      const updatedActivity = await this.activityRepository.save(activity);

      this.logger.log(`Successfully uploaded image for activity: ${activityId}`);
      return updatedActivity;
    } catch (error) {
      this.logger.error(`Failed to upload image: ${error.message}`);
      throw error;
    }
  }

  async getImagesForActivity(activityId: string): Promise<{ images: string[] }> {
      this.logger.log(`Fetching images for activity: ${activityId}`);
      try {
        const activity = await this.activityRepository.findOne({
          where: { id: activityId },
        });
  
        if (!activity) {
          throw new NotFoundException('Activity not found');
        }
  
        // Return full URLs for the images
        const baseUrl = process.env.BASE_URL || 'http://localhost:3000';
        const imageUrls = activity.references?.map(ref => `${baseUrl}${ref}`) || [];
  
        this.logger.log(`Successfully fetched images for activity: ${activityId}`);
        return { images: imageUrls };
      } catch (error) {
        this.logger.error(`Failed to fetch images: ${error.message}`);
        throw error;
      }
    }
}
