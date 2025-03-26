import { registerAs } from '@nestjs/config';
import * as dotenv from 'dotenv';
dotenv.config();
import { DataSourceOptions } from 'typeorm';


const databaseConfig: DataSourceOptions = {
    type: 'postgres',
    host: process.env.DATABASE_HOST,
    port: Number(process.env.DATABASE_PORT) || 5432,
    database: process.env.DATABASE_NAME,
    username: process.env.DATABASE_USERNAME,
    password: process.env.DATABASE_PASSWORD,
    entities: [__dirname + '/../**/*.entity{.ts,.js}'],
    synchronize: false,
    logging: process.env.NODE_ENV === 'dev' || process.env.NODE_ENV === 'local',
    migrations: [__dirname + '/../database/migrations/**/*{.ts,.js}'],
};

const databaseConfigModule = registerAs('database', () => databaseConfig);

export {
    databaseConfig,
    databaseConfigModule
}