import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Provinces } from './entities/Provinces';
import { Cities } from './entities/Cities';
import { Neighborhoods } from '../unitwork/entities/Neighborhoods';
import { CreateNeighborhoodDto } from '../user/dto/create-neighborhood.dto';

@Injectable()
export class LocationService {
  constructor(
    @InjectRepository(Provinces) private readonly provinceRepository: Repository<Provinces>,
    @InjectRepository(Cities) private readonly cityRepository: Repository<Cities>,
    @InjectRepository(Neighborhoods) private readonly neighborhoodRepository: Repository<Neighborhoods>,
  ) {}

  async findAllProvinces() {
    const provinces = await this.provinceRepository
      .createQueryBuilder('province')
      .select(['province.provinceName AS "provinceName"', 'province.idProvince AS "idProvince"'])
      .orderBy('province.provinceName')
      .getRawMany();

    if (!provinces) {
      return null;
    }
    return provinces;
  }

  async findAllCitiesByProvince(provinceName: string) {
    const cities = await this.provinceRepository
      .createQueryBuilder('province')
      .innerJoinAndSelect('province.cities', 'city')
      .where('province.provinceName = :provinceName', { provinceName })
      .select(['city.idCity AS "idCity"', 'city.cityName AS "cityName"'])
      .orderBy('city.cityName')
      .groupBy('city.idCity')
      .getRawMany();

    return cities;
  }

  async findAllNeighborhoods() {
    const rows = await this.neighborhoodRepository
      .createQueryBuilder('neighborhood')
      .innerJoin('neighborhood.city', 'city')
      .innerJoin('city.province', 'province')
      .where('neighborhood.deletedAt IS NULL')
      .select([
        'neighborhood.idNeighborhood AS "idNeighborhood"',
        'neighborhood.neighborhoodName AS "neighborhoodName"',
        'neighborhood.numBlocksInNeighborhood AS "numBlocksInNeighborhood"',
        'city.cityName AS "cityName"',
        'province.provinceName AS "provinceName"',
        'ST_AsGeoJSON(neighborhood.boundary) AS "boundaryGeoJson"',
      ])
      .getRawMany();

    return rows.map((n) => ({
      idNeighborhood: n.idNeighborhood,
      neighborhoodName: n.neighborhoodName,
      provinceName: n.provinceName,
      cityName: n.cityName,
      numBlocksInNeighborhood: n.numBlocksInNeighborhood,
      coordinates: n.boundaryGeoJson
        ? (JSON.parse(n.boundaryGeoJson).coordinates[0] as [number, number][])
            .slice(0, -1) // remove closing point (same as first)
            .map(([lng, lat]) => ({ latitude: lat, longitude: lng }))
        : [],
    }));
  }

  async createNeighborhood(createNeighborhoodDto: CreateNeighborhoodDto) {
    const city = await this.cityRepository.findOne({
      where: { cityName: createNeighborhoodDto.cityName, province: { provinceName: createNeighborhoodDto.provinceName } },
      relations: ['province'],
    });

    if (!city) {
      throw new BadRequestException('City not found');
    }

    const newNeighborhood = await this.neighborhoodRepository.save({
      city: city,
      neighborhoodName: createNeighborhoodDto.neighborhoodName,
      numBlocksInNeighborhood: createNeighborhoodDto.numBlocksInNeighborhood,
    });

    // Build a closed WKT polygon from the lat/long array (PostGIS expects longitude first)
    const coords = [...createNeighborhoodDto.coordinates, createNeighborhoodDto.coordinates[0]];
    const wkt = `POLYGON((${coords.map((c) => `${c.longitude} ${c.latitude}`).join(', ')}))`;
    await this.neighborhoodRepository.query(
      `UPDATE neighborhoods SET boundary = ST_GeomFromText($1, 4326)::geography WHERE id_neighborhood = $2`,
      [wkt, newNeighborhood.idNeighborhood],
    );

    return true;
  }

  async removeNeighborhoodById(idNeighborhood: number) {
    const neighborhood = await this.neighborhoodRepository.findOne({
      where: { idNeighborhood },
      relations: ['unitWorks'],
    });

    if (!neighborhood) {
      throw new NotFoundException('Neighborhood not found');
    }

    if (neighborhood.unitWorks?.length > 0) {
      throw new BadRequestException('Cannot delete neighborhood: it has associated unit works');
    }

    const treeCount = await this.neighborhoodRepository
      .createQueryBuilder('neighborhood')
      .innerJoin('neighborhood.trees', 'tree')
      .where('neighborhood.idNeighborhood = :idNeighborhood', { idNeighborhood })
      .getCount();

    if (treeCount > 0) {
      throw new BadRequestException('Cannot delete neighborhood: it has associated trees');
    }

    await this.neighborhoodRepository.delete(idNeighborhood);
    return true;
  }
}
