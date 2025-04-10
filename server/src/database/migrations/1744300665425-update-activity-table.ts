import { MigrationInterface, QueryRunner } from "typeorm";

export class UpdateActivityTable1744300665425 implements MigrationInterface {
    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`
            ALTER TABLE "activity" 
            DROP CONSTRAINT "FK_9a8b7d51dee30e0bf3f537b8719"
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`
            ALTER TABLE "activity" 
            ADD CONSTRAINT "FK_9a8b7d51dee30e0bf3f537b8719" 
            FOREIGN KEY ("paidById") 
            REFERENCES "user"("id")
        `);
    }
}
