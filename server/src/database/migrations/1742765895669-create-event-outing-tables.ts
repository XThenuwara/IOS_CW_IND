import { MigrationInterface, QueryRunner } from "typeorm";

export class CreateEventOutingTables1742765895669 implements MigrationInterface {
    name = 'CreateEventOutingTables1742765895669'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "user" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "name" character varying NOT NULL, "email" character varying NOT NULL, "password" character varying NOT NULL, "avatar" character varying, "paymentMethods" text NOT NULL DEFAULT '[]', "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "UQ_e12875dfb3b1d92d7d7c5377e22" UNIQUE ("email"), CONSTRAINT "PK_cace4a159ff9f2512dd42373760" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "activity" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "amount" numeric(10,2) NOT NULL, "title" character varying NOT NULL, "description" character varying NOT NULL, "references" text NOT NULL, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), "paidById" uuid, "outingId" uuid, CONSTRAINT "PK_24625a1d6b1b089c8ae206fe467" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "outing_event" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "tickets" json NOT NULL, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), "outingId" uuid, "eventId" uuid, CONSTRAINT "PK_3f27a349ea3bc016bc7597a9ff1" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "outing" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "title" character varying NOT NULL, "description" character varying NOT NULL, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), "ownerId" uuid, CONSTRAINT "PK_25701e87e08e64aa52320321f83" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "activity_participants_user" ("activityId" uuid NOT NULL, "userId" uuid NOT NULL, CONSTRAINT "PK_c8593f9b410aca5aa42309fb7dd" PRIMARY KEY ("activityId", "userId"))`);
        await queryRunner.query(`CREATE INDEX "IDX_6135e64becd054f70704fe1288" ON "activity_participants_user" ("activityId") `);
        await queryRunner.query(`CREATE INDEX "IDX_8c36a4d8b5f71db8230fa3aceb" ON "activity_participants_user" ("userId") `);
        await queryRunner.query(`CREATE TABLE "outing_participants_user" ("outingId" uuid NOT NULL, "userId" uuid NOT NULL, CONSTRAINT "PK_1eeec7316a00ff4987815e3fcf4" PRIMARY KEY ("outingId", "userId"))`);
        await queryRunner.query(`CREATE INDEX "IDX_f805afe18e21ed61e10d59f06e" ON "outing_participants_user" ("outingId") `);
        await queryRunner.query(`CREATE INDEX "IDX_2a704e3d02e0b6ca5d6afc93fa" ON "outing_participants_user" ("userId") `);
        await queryRunner.query(`ALTER TABLE "activity" ADD CONSTRAINT "FK_9a8b7d51dee30e0bf3f537b8719" FOREIGN KEY ("paidById") REFERENCES "user"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "activity" ADD CONSTRAINT "FK_2e68e8bf4cc8c81a3587b191fa5" FOREIGN KEY ("outingId") REFERENCES "outing"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "outing_event" ADD CONSTRAINT "FK_486126f87d52eeb325bdc8d5533" FOREIGN KEY ("outingId") REFERENCES "outing"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "outing_event" ADD CONSTRAINT "FK_176353c3c8d508431f49cc8b4a9" FOREIGN KEY ("eventId") REFERENCES "event"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "outing" ADD CONSTRAINT "FK_9e6cf36f2305ec3d374466b827f" FOREIGN KEY ("ownerId") REFERENCES "user"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "activity_participants_user" ADD CONSTRAINT "FK_6135e64becd054f70704fe1288a" FOREIGN KEY ("activityId") REFERENCES "activity"("id") ON DELETE CASCADE ON UPDATE CASCADE`);
        await queryRunner.query(`ALTER TABLE "activity_participants_user" ADD CONSTRAINT "FK_8c36a4d8b5f71db8230fa3acebc" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE`);
        await queryRunner.query(`ALTER TABLE "outing_participants_user" ADD CONSTRAINT "FK_f805afe18e21ed61e10d59f06e5" FOREIGN KEY ("outingId") REFERENCES "outing"("id") ON DELETE CASCADE ON UPDATE CASCADE`);
        await queryRunner.query(`ALTER TABLE "outing_participants_user" ADD CONSTRAINT "FK_2a704e3d02e0b6ca5d6afc93fad" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "outing_participants_user" DROP CONSTRAINT "FK_2a704e3d02e0b6ca5d6afc93fad"`);
        await queryRunner.query(`ALTER TABLE "outing_participants_user" DROP CONSTRAINT "FK_f805afe18e21ed61e10d59f06e5"`);
        await queryRunner.query(`ALTER TABLE "activity_participants_user" DROP CONSTRAINT "FK_8c36a4d8b5f71db8230fa3acebc"`);
        await queryRunner.query(`ALTER TABLE "activity_participants_user" DROP CONSTRAINT "FK_6135e64becd054f70704fe1288a"`);
        await queryRunner.query(`ALTER TABLE "outing" DROP CONSTRAINT "FK_9e6cf36f2305ec3d374466b827f"`);
        await queryRunner.query(`ALTER TABLE "outing_event" DROP CONSTRAINT "FK_176353c3c8d508431f49cc8b4a9"`);
        await queryRunner.query(`ALTER TABLE "outing_event" DROP CONSTRAINT "FK_486126f87d52eeb325bdc8d5533"`);
        await queryRunner.query(`ALTER TABLE "activity" DROP CONSTRAINT "FK_2e68e8bf4cc8c81a3587b191fa5"`);
        await queryRunner.query(`ALTER TABLE "activity" DROP CONSTRAINT "FK_9a8b7d51dee30e0bf3f537b8719"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_2a704e3d02e0b6ca5d6afc93fa"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_f805afe18e21ed61e10d59f06e"`);
        await queryRunner.query(`DROP TABLE "outing_participants_user"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_8c36a4d8b5f71db8230fa3aceb"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_6135e64becd054f70704fe1288"`);
        await queryRunner.query(`DROP TABLE "activity_participants_user"`);
        await queryRunner.query(`DROP TABLE "outing"`);
        await queryRunner.query(`DROP TABLE "outing_event"`);
        await queryRunner.query(`DROP TABLE "activity"`);
        await queryRunner.query(`DROP TABLE "user"`);
    }

}
