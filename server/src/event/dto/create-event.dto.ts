import { IsString, IsArray, IsNumber, IsDateString, IsEmail, ValidateNested, IsNotEmpty } from 'class-validator';
import { Type } from 'class-transformer';

class TicketTypeDto {
    @IsString()
    @IsNotEmpty()
    name: string;

    @IsNumber()
    @IsNotEmpty()
    price: number;

    @IsNumber()
    @IsNotEmpty()
    totalQuantity: number;

    @IsNumber()
    soldQuantity: number;
}

export class CreateEventDto {
    @IsString()
    @IsNotEmpty()
    title: string;

    @IsString()
    @IsNotEmpty()
    description: string;

    @IsString()
    @IsNotEmpty()
    locationName: string;

    @IsString()
    @IsNotEmpty()
    locationAddress: string;

    @IsString()
    @IsNotEmpty()
    locationLongitudeLatitude: string;

    @IsDateString()
    @IsNotEmpty()
    eventDate: Date;

    @IsString()
    @IsNotEmpty()
    organizerName: string;

    @IsString()
    @IsNotEmpty()
    organizerPhone: string;

    @IsEmail()
    @IsNotEmpty()
    organizerEmail: string;

    @IsArray()
    @IsString({ each: true })
    @IsNotEmpty()
    amenities: string[];

    @IsArray()
    @IsString({ each: true })
    @IsNotEmpty()
    requirements: string[];

    @IsString()
    @IsNotEmpty()
    weatherCondition: string;

    @IsNumber()
    @IsNotEmpty()
    capacity: number;

    @ValidateNested({ each: true })
    @Type(() => TicketTypeDto)
    @IsNotEmpty()
    ticketTypes: TicketTypeDto[];
}