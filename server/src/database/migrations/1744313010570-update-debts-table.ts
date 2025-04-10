import { MigrationInterface, QueryRunner } from "typeorm";

export class UpdateDebtsTable1744313010570 implements MigrationInterface {
    name = 'UpdateDebtsTable1744313010570'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "debt" ADD "fromUserId" character varying NOT NULL`);
        await queryRunner.query(`ALTER TABLE "debt" ADD "toUserId" character varying NOT NULL`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "debt" DROP COLUMN "toUserId"`);
        await queryRunner.query(`ALTER TABLE "debt" DROP COLUMN "fromUserId"`);
    }

}
