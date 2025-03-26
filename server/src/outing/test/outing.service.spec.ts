import { Test, TestingModule } from '@nestjs/testing';
import { OutingService } from './outing.service';

describe('OutingService', () => {
  let service: OutingService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [OutingService],
    }).compile();

    service = module.get<OutingService>(OutingService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
