import { NestFactory } from '@nestjs/core';
import { AppModule } from '../../app.module';
import { DataSource } from 'typeorm';
import { seedOccupations } from './occupation.seed';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const dataSource = app.get(DataSource);

  console.log('🌱 Iniciando seeds...');

  await seedOccupations(dataSource);

  console.log('✅ Seeds completados');
  await app.close();
}

bootstrap().catch(err => {
  console.error('❌ Error en seeds:', err);
  process.exit(1);
});