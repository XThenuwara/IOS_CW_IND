import { MigrationInterface, QueryRunner } from "typeorm";

export class UpdatePurchaseTable1745046110624 implements MigrationInterface {
    name = 'UpdatePurchaseTable1745046110624'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "purchased_tickets" ADD "outingId" character varying`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "purchased_tickets" DROP COLUMN "outingId"`);
    }

}
