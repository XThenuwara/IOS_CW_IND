import { PartialType } from '@nestjs/mapped-types';
import { CreateOutingDto } from './create-outing.dto';

export class UpdateOutingDto extends PartialType(CreateOutingDto) {}
