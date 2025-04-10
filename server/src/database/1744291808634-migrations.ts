import { MigrationInterface, QueryRunner } from "typeorm";

export class Migrations1744291808634 implements MigrationInterface {
    name = 'Migrations1744291808634'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "activity" DROP CONSTRAINT "FK_9a8b7d51dee30e0bf3f537b8719"`);
        await queryRunner.query(`ALTER TABLE "activity" DROP COLUMN "paidById"`);
        await queryRunner.query(`ALTER TABLE "activity" ADD "paidById" character varying NOT NULL`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "activity" DROP COLUMN "paidById"`);
        await queryRunner.query(`ALTER TABLE "activity" ADD "paidById" uuid`);
        await queryRunner.query(`ALTER TABLE "activity" ADD CONSTRAINT "FK_9a8b7d51dee30e0bf3f537b8719" FOREIGN KEY ("paidById") REFERENCES "user"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
    }

}
