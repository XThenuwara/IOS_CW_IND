import { DataSource } from 'typeorm';
import * as dotenv from 'dotenv';
dotenv.config();
import { databaseConfig } from '../config/database.config'

const AppDataSource = new DataSource({
    ...databaseConfig,
    migrations: [__dirname + '/migrations/**/*{.ts,.js}'],
});

export default AppDataSource;