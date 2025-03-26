import { MigrationInterface, QueryRunner } from "typeorm";

export class CreateEventTable1742759828462 implements MigrationInterface {
    name = 'CreateEventTable1742759828462'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "event" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "title" character varying NOT NULL, "description" character varying NOT NULL, "locationName" character varying NOT NULL, "locationAddress" character varying NOT NULL, "locationLongitudeLatitude" character varying NOT NULL, "eventDate" TIMESTAMP NOT NULL, "organizerName" character varying NOT NULL, "organizerPhone" character varying NOT NULL, "organizerEmail" character varying NOT NULL, "amenities" text NOT NULL, "requirements" text NOT NULL, "weatherCondition" character varying NOT NULL, "capacity" integer NOT NULL, "sold" integer NOT NULL DEFAULT '0', "ticketTypes" json NOT NULL, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_30c2f3bbaf6d34a55f8ae6e4614" PRIMARY KEY ("id"))`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP TABLE "event"`);
    }

}
