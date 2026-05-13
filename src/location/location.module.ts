import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LocationService } from './location.service';
import { LocationController } from './location.controller';
import { Provinces } from './entities/Provinces';
import { Cities } from './entities/Cities';
import { Neighborhoods } from '../unitwork/entities/Neighborhoods';

@Module({
  imports: [TypeOrmModule.forFeature([Provinces, Cities, Neighborhoods])],
  providers: [LocationService],
  controllers: [LocationController],
})
export class LocationModule {}
