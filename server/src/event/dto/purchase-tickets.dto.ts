import { IsUUID, IsArray, ValidateNested, IsString, IsNumber, Min, IsOptional } from 'class-validator';
import { Type } from 'class-transformer';

class TicketPurchaseItem {
    @IsString()
    ticketType: string;

    @IsNumber()
    @Min(1)
    quantity: number;
}

export class PurchaseTicketsDto {
    @IsUUID()
    eventId: string;

    @IsArray()
    @ValidateNested({ each: true })
    @Type(() => TicketPurchaseItem)
    tickets: TicketPurchaseItem[];

    @IsString()
    paymentMethod: string;
}