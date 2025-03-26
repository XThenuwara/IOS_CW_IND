import { DataSource } from 'typeorm';
import { runSeeders } from 'typeorm-extension';
import AppDataSource from './database.source';
import EventSeeder from './seeds/event.seed';

const runSeeds = async () => {
    await AppDataSource.initialize();
    
    await runSeeders(AppDataSource, {
        seeds: [EventSeeder]
    });
    
    console.log('Seeds executed successfully');
    process.exit(0);
};

runSeeds().catch(error => {
    console.error('Error running seeds:', error);
    process.exit(1);
});