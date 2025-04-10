import { MigrationInterface, QueryRunner } from "typeorm";

export class UpdateActivtiyEntityColumns1743796608889 implements MigrationInterface {
    name = 'UpdateActivtiyEntityColumns1743796608889'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "activity" ALTER COLUMN "references" DROP NOT NULL`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "activity" ALTER COLUMN "references" SET NOT NULL`);
    }

}
