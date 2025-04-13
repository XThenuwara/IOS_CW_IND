import { MigrationInterface, QueryRunner } from "typeorm";

export class UpdateNotificationTable1744478260083 implements MigrationInterface {
    name = 'UpdateNotificationTable1744478260083'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "notifications" ADD "referenceId" character varying NOT NULL`);
        await queryRunner.query(`ALTER TABLE "notifications" DROP COLUMN "type"`);
        await queryRunner.query(`CREATE TYPE "public"."notifications_type_enum" AS ENUM('ADDED_TO_OUTING', 'ADDED_TO_ACTIVITY', 'SETTLE_UP_REMINDER', 'ADDED_TO_GROUP')`);
        await queryRunner.query(`ALTER TABLE "notifications" ADD "type" "public"."notifications_type_enum" NOT NULL DEFAULT 'ADDED_TO_OUTING'`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "notifications" DROP COLUMN "type"`);
        await queryRunner.query(`DROP TYPE "public"."notifications_type_enum"`);
        await queryRunner.query(`ALTER TABLE "notifications" ADD "type" character varying NOT NULL`);
        await queryRunner.query(`ALTER TABLE "notifications" DROP COLUMN "referenceId"`);
    }

}
