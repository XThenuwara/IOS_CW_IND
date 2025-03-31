import { MigrationInterface, QueryRunner } from "typeorm";

export class AddPhoneNumberToUser1743434126535 implements MigrationInterface {
    name = 'AddPhoneNumberToUser1743434126535'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "group" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "name" character varying NOT NULL, "description" character varying, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), "ownerId" uuid, CONSTRAINT "PK_256aa0fda9b1de1a73ee0b7106b" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "group_members" ("group_id" uuid NOT NULL, "user_id" uuid NOT NULL, CONSTRAINT "PK_f5939ee0ad233ad35e03f5c65c1" PRIMARY KEY ("group_id", "user_id"))`);
        await queryRunner.query(`CREATE INDEX "IDX_2c840df5db52dc6b4a1b0b69c6" ON "group_members" ("group_id") `);
        await queryRunner.query(`CREATE INDEX "IDX_20a555b299f75843aa53ff8b0e" ON "group_members" ("user_id") `);
        await queryRunner.query(`ALTER TABLE "user" ADD "phoneNumber" character varying`);
        await queryRunner.query(`ALTER TYPE "public"."outing_status_enum" RENAME TO "outing_status_enum_old"`);
        await queryRunner.query(`CREATE TYPE "public"."outing_status_enum" AS ENUM('draft', 'in_progress', 'unsettled', 'settled')`);
        await queryRunner.query(`ALTER TABLE "outing" ALTER COLUMN "status" DROP DEFAULT`);
        await queryRunner.query(`ALTER TABLE "outing" ALTER COLUMN "status" TYPE "public"."outing_status_enum" USING "status"::"text"::"public"."outing_status_enum"`);
        await queryRunner.query(`ALTER TABLE "outing" ALTER COLUMN "status" SET DEFAULT 'draft'`);
        await queryRunner.query(`DROP TYPE "public"."outing_status_enum_old"`);
        await queryRunner.query(`ALTER TABLE "group" ADD CONSTRAINT "FK_af997e6623c9a0e27c241126988" FOREIGN KEY ("ownerId") REFERENCES "user"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "group_members" ADD CONSTRAINT "FK_2c840df5db52dc6b4a1b0b69c6e" FOREIGN KEY ("group_id") REFERENCES "group"("id") ON DELETE CASCADE ON UPDATE CASCADE`);
        await queryRunner.query(`ALTER TABLE "group_members" ADD CONSTRAINT "FK_20a555b299f75843aa53ff8b0ee" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "group_members" DROP CONSTRAINT "FK_20a555b299f75843aa53ff8b0ee"`);
        await queryRunner.query(`ALTER TABLE "group_members" DROP CONSTRAINT "FK_2c840df5db52dc6b4a1b0b69c6e"`);
        await queryRunner.query(`ALTER TABLE "group" DROP CONSTRAINT "FK_af997e6623c9a0e27c241126988"`);
        await queryRunner.query(`CREATE TYPE "public"."outing_status_enum_old" AS ENUM('in_progress', 'unsettled', 'settled')`);
        await queryRunner.query(`ALTER TABLE "outing" ALTER COLUMN "status" DROP DEFAULT`);
        await queryRunner.query(`ALTER TABLE "outing" ALTER COLUMN "status" TYPE "public"."outing_status_enum_old" USING "status"::"text"::"public"."outing_status_enum_old"`);
        await queryRunner.query(`ALTER TABLE "outing" ALTER COLUMN "status" SET DEFAULT 'in_progress'`);
        await queryRunner.query(`DROP TYPE "public"."outing_status_enum"`);
        await queryRunner.query(`ALTER TYPE "public"."outing_status_enum_old" RENAME TO "outing_status_enum"`);
        await queryRunner.query(`ALTER TABLE "user" DROP COLUMN "phoneNumber"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_20a555b299f75843aa53ff8b0e"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_2c840df5db52dc6b4a1b0b69c6"`);
        await queryRunner.query(`DROP TABLE "group_members"`);
        await queryRunner.query(`DROP TABLE "group"`);
    }

}
