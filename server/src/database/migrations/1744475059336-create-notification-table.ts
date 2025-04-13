import { MigrationInterface, QueryRunner } from "typeorm";

export class CreateNotificationTable1744475059336 implements MigrationInterface {
    name = 'CreateNotificationTable1744475059336'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "notifications" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "user_id" uuid NOT NULL, "type" character varying NOT NULL, "title" character varying NOT NULL, "message" character varying NOT NULL, "sent_at" TIMESTAMP NOT NULL DEFAULT now(), "read_at" TIMESTAMP, CONSTRAINT "PK_6a72c3c0f683f6462415e653c3a" PRIMARY KEY ("id"))`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP TABLE "notifications"`);
    }

}
