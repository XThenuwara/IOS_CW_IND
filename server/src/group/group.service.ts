import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Group } from './entities/group.entity';
import { User } from '../user/entities/user.entity';
import { CreateGroupDto } from './dto/create-group.dto';
import { UpdateGroupDto } from './dto/update-group.dto';

@Injectable()
export class GroupService {
  constructor(
    @InjectRepository(Group)
    private groupRepository: Repository<Group>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  async create(createGroupDto: CreateGroupDto, userId: string) {
    const owner = await this.userRepository.findOne({ where: { id: userId } });
    if (!owner) {
      throw new NotFoundException('User not found');
    }

    const members = await this.userRepository.findByIds(createGroupDto.memberIds);
    
    const group = this.groupRepository.create({
      ...createGroupDto,
      owner,
      members: [owner, ...members]
    });

    return this.groupRepository.save(group);
  }

  async findAll(userId: string) {
    return this.groupRepository.find({
      where: [
        { owner: { id: userId } },
        { members: { id: userId } }
      ]
    });
  }

  async findOne(id: string, userId: string) {
    const group = await this.groupRepository.findOne({
      where: [
        { id, owner: { id: userId } },
        { id, members: { id: userId } }
      ]
    });

    if (!group) {
      throw new NotFoundException('Group not found');
    }

    return group;
  }

  async update(id: string, updateGroupDto: UpdateGroupDto, userId: string) {
    const group = await this.groupRepository.findOne({
      where: { id, owner: { id: userId } }
    });

    if (!group) {
      throw new NotFoundException('Group not found or you are not the owner');
    }

    if (updateGroupDto.memberIds) {
      const members = await this.userRepository.findByIds(updateGroupDto.memberIds);
      group.members = [group.owner, ...members];
    }

    Object.assign(group, updateGroupDto);
    return this.groupRepository.save(group);
  }

  async addMember(groupId: string, memberId: string, userId: string) {
    const group = await this.groupRepository.findOne({
      where: { id: groupId, owner: { id: userId } }
    });

    if (!group) {
      throw new NotFoundException('Group not found or you are not the owner');
    }

    const newMember = await this.userRepository.findOne({ where: { id: memberId } });
    if (!newMember) {
      throw new NotFoundException('User not found');
    }

    if (group.members.some(member => member.id === memberId)) {
      throw new BadRequestException('User is already a member');
    }

    group.members = [...group.members, newMember];
    return this.groupRepository.save(group);
  }

  async removeMember(groupId: string, memberId: string, userId: string) {
    const group = await this.groupRepository.findOne({
      where: { id: groupId, owner: { id: userId } }
    });

    if (!group) {
      throw new NotFoundException('Group not found or you are not the owner');
    }

    if (group.owner.id === memberId) {
      throw new BadRequestException('Cannot remove the owner from the group');
    }

    group.members = group.members.filter(member => member.id !== memberId);
    return this.groupRepository.save(group);
  }

  async remove(id: string, userId: string) {
    const group = await this.groupRepository.findOne({
      where: { id, owner: { id: userId } }
    });

    if (!group) {
      throw new NotFoundException('Group not found or you are not the owner');
    }

    return this.groupRepository.remove(group);
  }

  async leaveGroup(groupId: string, userId: string) {
    const group = await this.groupRepository.findOne({
      where: { id: groupId, members: { id: userId } }
    });

    if (!group) {
      throw new NotFoundException('Group not found or you are not a member');
    }

    if (group.owner.id === userId) {
      throw new BadRequestException('Owner cannot leave the group. Transfer ownership or delete the group instead.');
    }

    group.members = group.members.filter(member => member.id !== userId);
    return this.groupRepository.save(group);
  }
}
