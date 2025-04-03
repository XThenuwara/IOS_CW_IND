import { Controller, Get, Post, Body, Patch, Param, Delete, Request, UseGuards } from '@nestjs/common';
import { GroupService } from './group.service';
import { CreateGroupDto } from './dto/create-group.dto';
import { UpdateGroupDto } from './dto/update-group.dto';
import { Roles, UserRole } from '../lib/decorator/role.decorator';

@Controller('group')
export class GroupController {
  constructor(private readonly groupService: GroupService) {}

  @Roles(UserRole.USER)
  @Post()
  create(@Body() createGroupDto: CreateGroupDto, @Request() req) {
    return this.groupService.create(createGroupDto, req.user.id);
  }

  @Roles(UserRole.USER)
  @Get()
  findAll(@Request() req) {
    return this.groupService.findAll(req.user.id);
  }

  @Roles(UserRole.USER)
  @Get(':id')
  findOne(@Param('id') id: string, @Request() req) {
    return this.groupService.findOne(id, req.user.id);
  }

  @Roles(UserRole.USER)
  @Patch(':id')
  update(@Param('id') id: string, @Body() updateGroupDto: UpdateGroupDto, @Request() req) {
    return this.groupService.update(id, updateGroupDto, req.user.id);
  }

  @Roles(UserRole.USER)
  @Delete(':id')
  remove(@Param('id') id: string, @Request() req) {
    return this.groupService.remove(id, req.user.id);
  }

  @Roles(UserRole.USER)
  @Post(':id/members/:memberId')
  addMember(@Param('id') id: string, @Param('memberId') memberId: string, @Request() req) {
    return this.groupService.addMember(id, memberId, req.user.id);
  }

  @Roles(UserRole.USER)
  @Delete(':id/members/:memberId')
  removeMember(@Param('id') id: string, @Param('memberId') memberId: string, @Request() req) {
    return this.groupService.removeMember(id, memberId, req.user.id);
  }

  @Roles(UserRole.USER)
  @Delete(':id/leave')
  leaveGroup(@Param('id') id: string, @Request() req) {
    return this.groupService.leaveGroup(id, req.user.id);
  }
}
