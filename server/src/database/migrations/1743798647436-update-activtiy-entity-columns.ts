import { MigrationInterface, QueryRunner } from "typeorm";

export class UpdateActivtiyEntityColumns1743798647436 implements MigrationInterface {
    name = 'UpdateActivtiyEntityColumns1743798647436'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "activity" ALTER COLUMN "description" DROP NOT NULL`);
        await queryRunner.query(`ALTER TABLE "activity" ALTER COLUMN "category" DROP NOT NULL`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "activity" ALTER COLUMN "category" SET NOT NULL`);
        await queryRunner.query(`ALTER TABLE "activity" ALTER COLUMN "description" SET NOT NULL`);
    }

}
