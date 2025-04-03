import { MigrationInterface, QueryRunner } from "typeorm";

export class UpdatesToOutingTable1743511370557 implements MigrationInterface {
    name = 'UpdatesToOutingTable1743511370557'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "outing" ADD "participants" text array NOT NULL DEFAULT '{}'`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "outing" DROP COLUMN "participants"`);
    }

}
