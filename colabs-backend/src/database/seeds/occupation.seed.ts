import { DataSource } from 'typeorm';
import { Occupation } from '../../modules/occupation/entities/occupation.entity';

export async function seedOccupations(dataSource: DataSource) {
  const occupationRepository = dataSource.getRepository(Occupation);

  const occupations = [
  { name: 'Electricidad' },
  { name: 'Gasfitería' },
  { name: 'Carpintería' },
  { name: 'Albañilería' },
  { name: 'Pintura' },
  { name: 'Jardinería' },
  { name: 'Cerrajería' },
  { name: 'Fumigación' },
  { name: 'Limpieza del hogar' },
  { name: 'Mudanza' },
  { name: 'Refrigeración y AC' },
  { name: 'Techado' },
  { name: 'Soldadura' },
  { name: 'Mecánica' },
  { name: 'Electrónica' },
  { name: 'Repostería' },
  { name: 'Costura y Confección' },
  { name: 'Fotografía' },
  { name: 'Clases particulares' },
];

  for (const occ of occupations) {
    const exists = await occupationRepository.findOne({
      where: { name: occ.name },
    });

    if (!exists) {
      const occupation = occupationRepository.create({
        name: occ.name,
        status: 'active',
      });
      await occupationRepository.save(occupation);
      console.log(`✅ Occupation creada: ${occ.name}`);
    } else {
      console.log(`⏭️  Ya existe: ${occ.name}`);
    }
  }
}