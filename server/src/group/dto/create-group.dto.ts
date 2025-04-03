import { IsString, IsNotEmpty, IsArray, IsOptional, IsUUID } from 'class-validator';

export class CreateGroupDto {
    @IsString()
    @IsNotEmpty()
    name: string;

    @IsString()
    @IsOptional()
    description?: string;

    @IsArray()
    @IsUUID('4', { each: true })
    @IsOptional()
    memberIds: string[];
}