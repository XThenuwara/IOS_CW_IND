import { MigrationInterface, QueryRunner } from "typeorm";

export class UpdateEventTableAddEventType1743063294193 implements MigrationInterface {
    name = 'UpdateEventTableAddEventType1743063294193'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "activity" ADD "category" character varying NOT NULL`);
        await queryRunner.query(`CREATE TYPE "public"."event_eventtype_enum" AS ENUM('musical', 'sports', 'food', 'art')`);
        await queryRunner.query(`ALTER TABLE "event" ADD "eventType" "public"."event_eventtype_enum" NOT NULL DEFAULT 'musical'`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "event" DROP COLUMN "eventType"`);
        await queryRunner.query(`DROP TYPE "public"."event_eventtype_enum"`);
        await queryRunner.query(`ALTER TABLE "activity" DROP COLUMN "category"`);
    }

}
