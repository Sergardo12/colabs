import { MigrationInterface, QueryRunner } from 'typeorm';

interface DuplicateRow {
  service_request_id: string;
  report_count: string;
}

export class AddUniqueReportPerServiceRequest1795046400000 implements MigrationInterface {
  name = 'AddUniqueReportPerServiceRequest1795046400000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    const duplicates = (await queryRunner.query(`
      SELECT
        service_request_id,
        COUNT(*)::text AS report_count
      FROM reports
      WHERE service_request_id IS NOT NULL
      GROUP BY service_request_id
      HAVING COUNT(*) > 1
      ORDER BY service_request_id
    `)) as DuplicateRow[];

    if (duplicates.length > 0) {
      const ids = duplicates.map((row) => row.service_request_id).join(', ');
      throw new Error(
        `Migración abortada: existen service_request_id con más de un reporte. ` +
          `No se eliminó ningún dato. IDs duplicados: ${ids}. ` +
          `Detalle: ${JSON.stringify(duplicates)}`,
      );
    }

    await queryRunner.query(`
      CREATE UNIQUE INDEX IF NOT EXISTS uq_reports_service_request_id
      ON reports (service_request_id)
      WHERE service_request_id IS NOT NULL
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      DROP INDEX IF EXISTS uq_reports_service_request_id
    `);
  }
}
