import { MigrationInterface, QueryRunner } from "typeorm";

export class AddUserRoleToUserEntity1743146698382 implements MigrationInterface {
    name = 'AddUserRoleToUserEntity1743146698382'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TYPE "public"."user_role_enum" AS ENUM('user', 'admin')`);
        await queryRunner.query(`ALTER TABLE "user" ADD "role" "public"."user_role_enum" NOT NULL DEFAULT 'user'`);
        await queryRunner.query(`CREATE TYPE "public"."outing_status_enum" AS ENUM('in_progress', 'unsettled', 'settled')`);
        await queryRunner.query(`ALTER TABLE "outing" ADD "status" "public"."outing_status_enum" NOT NULL DEFAULT 'in_progress'`);
        await queryRunner.query(`ALTER TYPE "public"."event_eventtype_enum" RENAME TO "event_eventtype_enum_old"`);
        await queryRunner.query(`CREATE TYPE "public"."event_eventtype_enum" AS ENUM('musical', 'sports', 'food', 'art', 'theater', 'movie', 'conference', 'other')`);
        await queryRunner.query(`ALTER TABLE "event" ALTER COLUMN "eventType" DROP DEFAULT`);
        await queryRunner.query(`ALTER TABLE "event" ALTER COLUMN "eventType" TYPE "public"."event_eventtype_enum" USING "eventType"::"text"::"public"."event_eventtype_enum"`);
        await queryRunner.query(`ALTER TABLE "event" ALTER COLUMN "eventType" SET DEFAULT 'musical'`);
        await queryRunner.query(`DROP TYPE "public"."event_eventtype_enum_old"`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TYPE "public"."event_eventtype_enum_old" AS ENUM('musical', 'sports', 'food', 'art')`);
        await queryRunner.query(`ALTER TABLE "event" ALTER COLUMN "eventType" DROP DEFAULT`);
        await queryRunner.query(`ALTER TABLE "event" ALTER COLUMN "eventType" TYPE "public"."event_eventtype_enum_old" USING "eventType"::"text"::"public"."event_eventtype_enum_old"`);
        await queryRunner.query(`ALTER TABLE "event" ALTER COLUMN "eventType" SET DEFAULT 'musical'`);
        await queryRunner.query(`DROP TYPE "public"."event_eventtype_enum"`);
        await queryRunner.query(`ALTER TYPE "public"."event_eventtype_enum_old" RENAME TO "event_eventtype_enum"`);
        await queryRunner.query(`ALTER TABLE "outing" DROP COLUMN "status"`);
        await queryRunner.query(`DROP TYPE "public"."outing_status_enum"`);
        await queryRunner.query(`ALTER TABLE "user" DROP COLUMN "role"`);
        await queryRunner.query(`DROP TYPE "public"."user_role_enum"`);
    }

}
