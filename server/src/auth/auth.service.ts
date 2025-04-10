import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  Logger
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { User } from '../user/entities/user.entity';
import { SignUpDto } from './dto/sign-up.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private jwtService: JwtService,
  ) {}

  async signUp(signUpDto: SignUpDto) {
    this.logger.log(`Attempting to sign up user with email: ${signUpDto.email}`);
    
    const existingUser = await this.userRepository.findOne({
      where: { email: signUpDto.email },
    });

    if (existingUser) {
      this.logger.warn(`Sign up failed: Email already exists - ${signUpDto.email}`);
      throw new ConflictException('Email already exists');
    }

    const hashedPassword = await bcrypt.hash(signUpDto.password, 10);
    const user = this.userRepository.create({
      ...signUpDto,
      password: hashedPassword,
    });

    await this.userRepository.save(user);
    this.logger.log(`User successfully created with ID: ${user.id}`);
    
    const { password, ...result } = user;
    const payload = { id: user.id, email: user.email, role: user.role };
    const token = await this.jwtService.signAsync(payload);

    return {
      accessToken: token,
      user: result,
    };
  }

  async login(loginDto: LoginDto) {
    this.logger.log(`Login attempt for email: ${loginDto.email}`);
    
    const user = await this.userRepository.findOne({
      where: { email: loginDto.email },
    });

    if (!user) {
      this.logger.warn(`Login failed: User not found - ${loginDto.email}`);
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(
      loginDto.password,
      user.password,
    );

    if (!isPasswordValid) {
      this.logger.warn(`Login failed: Invalid password for user - ${loginDto.email}`);
      throw new UnauthorizedException('Invalid credentials');
    }

    this.logger.log(`User successfully logged in: ${user.id}`);
    const payload = { id: user.id, email: user.email, role: user.role };
    const token = await this.jwtService.signAsync(payload);

    return {
      accessToken: token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        phoneNumber: user.phoneNumber,
      },
    };
  }

  async getUser(userId: string) {
    this.logger.log(`Fetching user profile: ${userId}`);
    
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      this.logger.warn(`User not found: ${userId}`);
      throw new UnauthorizedException('User not found');
    }

    this.logger.log(`User profile retrieved: ${userId}`);
    const { password, ...result } = user;
    return result;
  }
}
