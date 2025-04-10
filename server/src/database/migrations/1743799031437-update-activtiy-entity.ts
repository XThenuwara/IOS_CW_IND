import { MigrationInterface, QueryRunner } from "typeorm";

export class UpdateActivtiyEntity1743799031437 implements MigrationInterface {
    name = 'UpdateActivtiyEntity1743799031437'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "activity" ADD "participants" text`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "activity" DROP COLUMN "participants"`);
    }

}
