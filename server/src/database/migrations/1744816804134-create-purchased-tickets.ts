import { MigrationInterface, QueryRunner } from "typeorm";

export class CreatePurchasedTickets1744816804134 implements MigrationInterface {
    name = 'CreatePurchasedTickets1744816804134'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "purchased_tickets" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "userId" uuid NOT NULL, "eventId" uuid NOT NULL, "ticketType" character varying NOT NULL, "quantity" integer NOT NULL, "unitPrice" numeric(10,2) NOT NULL, "totalAmount" numeric(10,2) NOT NULL, "status" character varying NOT NULL DEFAULT 'pending', "paymentMethod" character varying, "paymentReference" character varying, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_b3ae26cab37c72cd1f00b062000" PRIMARY KEY ("id"))`);
        await queryRunner.query(`ALTER TABLE "purchased_tickets" ADD CONSTRAINT "FK_d41effb9ec4286d50bb5bdbfa6d" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "purchased_tickets" ADD CONSTRAINT "FK_7371aba3bf9a03822029eda6105" FOREIGN KEY ("eventId") REFERENCES "event"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "purchased_tickets" DROP CONSTRAINT "FK_7371aba3bf9a03822029eda6105"`);
        await queryRunner.query(`ALTER TABLE "purchased_tickets" DROP CONSTRAINT "FK_d41effb9ec4286d50bb5bdbfa6d"`);
        await queryRunner.query(`DROP TABLE "purchased_tickets"`);
    }

}
