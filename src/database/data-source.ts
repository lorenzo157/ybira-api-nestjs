import { DataSource } from 'typeorm';
import * as dotenv from 'dotenv';

dotenv.config();

export const AppDataSource = new DataSource({
  type: 'postgres',
  host: process.env.DATABASE_APPLICATION_HOST,
  port: parseInt(process.env.DATABASE_APPLICATION_PORT),
  username: process.env.DATABASE_APPLICATION_USERNAME,
  password: process.env.DATABASE_APPLICATION_PASSWORD,
  database: process.env.DATABASE_APPLICATION_DATABASE,
  schema: process.env.DATABASE_APPLICATION_SCHEMA,
  entities: [__dirname + '/../**/entities/*.{ts,js}'],
  migrations: [__dirname + '/../../migrations/**/*{.ts,.js}'],
  synchronize: false,
});
