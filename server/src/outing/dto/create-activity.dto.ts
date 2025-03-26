import { IsString, IsNumber, IsArray, IsOptional } from 'class-validator';

export class CreateActivityDto {
    @IsString()
    title: string;

    @IsString()
    description: string;

    @IsNumber()
    amount: number;

    @IsArray()
    @IsString({ each: true })
    @IsOptional()
    references: string[];

    @IsArray()
    @IsString({ each: true })
    participantIds: string[];
}