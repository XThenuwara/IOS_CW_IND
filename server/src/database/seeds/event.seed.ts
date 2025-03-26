import { Event } from '../../event/entities/event.entity';
import { DataSource } from 'typeorm';
import { Seeder } from 'typeorm-extension';

export default class EventSeeder implements Seeder {
    public async run(dataSource: DataSource): Promise<void> {
        const eventRepository = dataSource.getRepository(Event);

        const events = [
            {
                title: 'Summer Music Festival 2024',
                description: 'Join us for the biggest music festival of the summer featuring top artists and bands.',
                locationName: 'Central Park',
                locationAddress: '123 Park Avenue, Colombo 07',
                locationLongitudeLatitude: '6.927079,79.861243',
                eventDate: new Date('2024-07-15T18:00:00'),
                organizerName: 'EventPro Lanka',
                organizerPhone: '+94 77 123 4567',
                organizerEmail: 'contact@eventpro.lk',
                amenities: ['Parking', 'Food Court', 'Security Service', 'First Aid'],
                requirements: ['Valid ID', 'No Outside Food', 'No Cameras'],
                weatherCondition: 'Outdoor',
                capacity: 1000,
                sold: 0,
                ticketTypes: [
                    {
                        name: 'VIP',
                        price: 15000.00,
                        totalQuantity: 100,
                        soldQuantity: 0
                    },
                    {
                        name: 'Regular',
                        price: 5000.00,
                        totalQuantity: 900,
                        soldQuantity: 0
                    }
                ]
            },
            {
                title: 'Tech Conference 2024',
                description: 'Annual technology conference featuring industry leaders and innovative showcases.',
                locationName: 'BMICH',
                locationAddress: 'Bauddhaloka Mawatha, Colombo 07',
                locationLongitudeLatitude: '6.900859,79.868672',
                eventDate: new Date('2024-08-20T09:00:00'),
                organizerName: 'TechSummit Lanka',
                organizerPhone: '+94 77 987 6543',
                organizerEmail: 'info@techsummit.lk',
                amenities: ['WiFi', 'Air Conditioning', 'Parking', 'Lunch Included'],
                requirements: ['Company ID', 'Registration Confirmation'],
                weatherCondition: 'Indoor',
                capacity: 500,
                sold: 0,
                ticketTypes: [
                    {
                        name: 'Early Bird',
                        price: 7500.00,
                        totalQuantity: 200,
                        soldQuantity: 0
                    },
                    {
                        name: 'Standard',
                        price: 10000.00,
                        totalQuantity: 300,
                        soldQuantity: 0
                    }
                ]
            }
        ];

        for (const event of events) {
            const existingEvent = await eventRepository.findOne({
                where: { title: event.title }
            });

            if (!existingEvent) {
                await eventRepository.save(event);
            }
        }
    }
}