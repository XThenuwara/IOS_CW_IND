import { PartialType } from '@nestjs/mapped-types';
import { CreateGroupDto } from './create-group.dto';
import { IsOptional, IsArray, IsUUID } from 'class-validator';

export class UpdateGroupDto extends PartialType(CreateGroupDto) {
    @IsArray()
    @IsUUID('4', { each: true })
    @IsOptional()
    memberIds?: string[];
}
