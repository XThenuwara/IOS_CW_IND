import { MigrationInterface, QueryRunner } from "typeorm";

export class CreateDebtsTable1744309469424 implements MigrationInterface {
    name = 'CreateDebtsTable1744309469424'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TYPE "public"."debt_status_enum" AS ENUM('pending', 'paid')`);
        await queryRunner.query(`CREATE TABLE "debt" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "amount" numeric(10,2) NOT NULL, "status" "public"."debt_status_enum" NOT NULL DEFAULT 'pending', "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "outingId" uuid, CONSTRAINT "PK_f0904ec85a9c8792dded33608a8" PRIMARY KEY ("id"))`);
        await queryRunner.query(`ALTER TABLE "activity" DROP COLUMN "paidById"`);
        await queryRunner.query(`ALTER TABLE "activity" ADD "paidById" character varying NOT NULL`);
        await queryRunner.query(`ALTER TABLE "debt" ADD CONSTRAINT "FK_171f86ae02aea957f2aebd62fba" FOREIGN KEY ("outingId") REFERENCES "outing"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "debt" DROP CONSTRAINT "FK_171f86ae02aea957f2aebd62fba"`);
        await queryRunner.query(`ALTER TABLE "activity" DROP COLUMN "paidById"`);
        await queryRunner.query(`ALTER TABLE "activity" ADD "paidById" uuid`);
        await queryRunner.query(`DROP TABLE "debt"`);
        await queryRunner.query(`DROP TYPE "public"."debt_status_enum"`);
    }

}
