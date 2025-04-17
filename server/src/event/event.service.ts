import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Event } from './entities/event.entity';
import { PurchasedTickets } from './entities/purchased-tickets.entity';
import { PurchaseTicketsDto } from './dto/purchase-tickets.dto';
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';

@Injectable()
export class EventService {
  constructor(
    @InjectRepository(Event)
    private eventRepository: Repository<Event>,
    @InjectRepository(PurchasedTickets)
    private purchasedTicketsRepository: Repository<PurchasedTickets>,
  ) {}

  async create(createEventDto: CreateEventDto): Promise<Event> {
    const event = this.eventRepository.create(createEventDto);
    return await this.eventRepository.save(event);
  }

  async findAll(): Promise<Event[]> {
    return await this.eventRepository.find();
  }

  async findOne(id: string): Promise<Event> {
    const event = await this.eventRepository.findOne({ where: { id } });
    if (!event) {
      throw new NotFoundException(`Event with ID ${id} not found`);
    }
    return event;
  }

  async update(id: string, updateEventDto: UpdateEventDto): Promise<Event> {
    const event = await this.findOne(id);
    Object.assign(event, updateEventDto);
    return await this.eventRepository.save(event);
  }

  async remove(id: string): Promise<void> {
    const result = await this.eventRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Event with ID ${id} not found`);
    }
  }

  async getPurchasedTickets(userId: string, eventId: string): Promise<PurchasedTickets[]> {
    return await this.purchasedTicketsRepository.find({
      where: {
        userId,
        eventId: eventId.toLowerCase()
      },
      order: {
        createdAt: 'DESC'
      }
    });
  }

  async getPurchasedTicketsForUser(userId: string): Promise<PurchasedTickets[]> {
    return await this.purchasedTicketsRepository.find({
      where: { userId },
      order: {
        createdAt: 'DESC'
      },
      relations: ['event']
    });
  }

  async purchaseTickets(userId: string, purchaseDto: PurchaseTicketsDto): Promise<PurchasedTickets> {
    const event = await this.findOne(purchaseDto.eventId.toLowerCase());
    
    let totalAmount = 0;
    for (const ticketItem of purchaseDto.tickets) {
      const ticketType = event.ticketTypes.find(t => t.name === ticketItem.ticketType);
      
      if (!ticketType) {
        throw new NotFoundException(`Ticket type ${ticketItem.ticketType} not found`);
      }
      
      if (ticketType.soldQuantity + ticketItem.quantity > ticketType.totalQuantity) {
        throw new BadRequestException(`Not enough tickets available for ${ticketType.name}`);
      }
      
      totalAmount += ticketType.price * ticketItem.quantity;

      ticketType.soldQuantity += ticketItem.quantity;
    }
    
    event.sold += purchaseDto.tickets.reduce((sum, item) => sum + item.quantity, 0);
    await this.eventRepository.save(event);
    
    const purchase = this.purchasedTicketsRepository.create({
      userId,
      eventId: event.id,
      ticketType: JSON.stringify(purchaseDto.tickets),
      quantity: purchaseDto.tickets.reduce((sum, item) => sum + item.quantity, 0),
      unitPrice: totalAmount / purchaseDto.tickets.reduce((sum, item) => sum + item.quantity, 0),
      totalAmount,
      status: 'completed',
      paymentMethod: purchaseDto.paymentMethod,
      paymentReference: `DEMO-${Date.now()}`
    });
    
    return await this.purchasedTicketsRepository.save(purchase);
  }
}
