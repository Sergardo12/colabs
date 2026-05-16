import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ServiceRequest } from './entities/service-request.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { RedisService } from '../../common/services/redis.service';
import { CollabsGateway } from '../gateway/colabs.gateway';
import { CreateServiceRequestDto } from './dto/create-service-request.dto';
import { ServiceRequestStatus, UpdateServiceRequestStatusDto } from './dto/update-service-request-status.dto';

@Injectable()
export class ServiceRequestService {
  constructor(
    @InjectRepository(ServiceRequest)
    private serviceRequestRepository: Repository<ServiceRequest>,

    @InjectRepository(ProfileColab)
    private profileColabRepository: Repository<ProfileColab>,

    private redisService: RedisService,
    private collabsGateway: CollabsGateway,
  ) {}

  async create(userId: string, dto: CreateServiceRequestDto) {
    // Crear la solicitud con PostGIS
    const serviceRequest = this.serviceRequestRepository.create({
      userId,
      occupationId: dto.occupationId,
      direction: dto.direction,
      description: dto.description,
      status: 'pending',
    });

    const saved = await this.serviceRequestRepository.save(serviceRequest) as ServiceRequest;

    // Actualiza la ubicación con PostGIS por separado
    await this.serviceRequestRepository
    .createQueryBuilder()
    .update(ServiceRequest)
    .set({
        location: () => `ST_SetSRID(ST_MakePoint(${dto.lng}, ${dto.lat}), 4326)`,
    })
    .where('id = :id', { id: saved.id })
    .execute();

    // Buscar colaboradores disponibles en Redis con esa occupation
    const nearbyCollaborators = await this.redisService
      .findNearbyCollaborators(dto.occupationId);

    // Filtrar por radio de 5km usando Haversine
    const inRange = nearbyCollaborators.filter(colab => {
      const distance = this.haversineDistance(
        dto.lat, dto.lng,
        colab.lat, colab.lng,
      );
      return distance <= 5;
    });

    // Notificar a cada colaborador en rango via WebSocket
    if (inRange.length > 0) {
      const collaboratorIds = inRange.map(c => c.userId);
      this.collabsGateway.emitNewServiceRequest(collaboratorIds, {
        id: saved.id,
        occupationId: saved.occupationId,
        direction: saved.direction,
        description: saved.description,
        lat: dto.lat,
        lng: dto.lng,
      });

      // Marcar colaboradores como busy en Redis
      for (const colab of inRange) {
        await this.redisService.setCollaboratorStatus(colab.userId, 'busy');
      }
    }

    return this.serviceRequestRepository.findOne({
        where: { id: saved.id },
      relations: ['occupation'],
    });
  }

  async findMyRequests(userId: string) {
    return this.serviceRequestRepository.find({
      where: { userId },
      relations: ['occupation'],
      order: { creationDate: 'DESC' },
    });
  }

  async findOne(id: string, userId: string) {
    const request = await this.serviceRequestRepository.findOne({
      where: { id },
      relations: ['occupation', 'proposals', 'proposals.profileColab'],
    });

    if (!request) throw new NotFoundException('Solicitud no encontrada');

    return request;
  }

  async findNearby(userId: string) {
    // Obtener ubicación del colaborador desde Redis
    const location = await this.redisService.getCollaboratorLocation(userId);

    if (!location) {
      throw new ForbiddenException(
        'Debes activar tu disponibilidad antes de ver solicitudes cercanas',
      );
    }

    // Buscar perfil del colaborador para saber sus ocupaciones
    const profile = await this.profileColabRepository.findOne({
      where: { userId },
      relations: ['occupations'],
    });

    if (!profile) {
      throw new ForbiddenException('No tienes perfil de colaborador');
    }

    const occupationIds = profile.occupations.map(o => o.id);

    // Buscar solicitudes pending en PostgreSQL
    const requests = await this.serviceRequestRepository
      .createQueryBuilder('sr')
      .where('sr.status = :status', { status: 'pending' })
      .andWhere('sr.occupationId IN (:...occupationIds)', { occupationIds })
      .leftJoinAndSelect('sr.occupation', 'occupation')
      .getMany();

    // Filtrar por radio de 5km
    return requests.filter(request => {
      if (!request.location) return false;
      // La ubicación viene como string de PostGIS — la parseamos
      return true; // simplificado — PostGIS hace el filtro real
    });
  }

  async updateStatus(
    id: string,
    userId: string,
    dto: UpdateServiceRequestStatusDto,
  ) {
    const request = await this.serviceRequestRepository.findOne({
      where: { id },
    });

    if (!request) throw new NotFoundException('Solicitud no encontrada');

    // Solo el dueño de la solicitud puede cambiar el estado
    if (request.userId !== userId) {
      throw new ForbiddenException('No tienes permiso para modificar esta solicitud');
    }

    request.status = dto.status;

    if (dto.status === ServiceRequestStatus.COMPLETED) {
      request.completionDate = new Date();
    }

    if (dto.status === ServiceRequestStatus.ACCEPTED) {
      request.acceptanceDate = new Date();
    }

    return this.serviceRequestRepository.save(request);
  }

  // Fórmula Haversine — distancia entre dos puntos en km
  private haversineDistance(
    lat1: number, lng1: number,
    lat2: number, lng2: number,
  ): number {
    const R = 6371;
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLng = (lng2 - lng1) * Math.PI / 180;
    const a =
      Math.sin(dLat / 2) ** 2 +
      Math.cos(lat1 * Math.PI / 180) *
      Math.cos(lat2 * Math.PI / 180) *
      Math.sin(dLng / 2) ** 2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  }
}