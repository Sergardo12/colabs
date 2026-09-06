import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Notification } from './entities/notification.entity';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { ServiceRequest } from '../service-request/entities/service-request.entity';
import { Proposal } from '../proposal/entities/proposal.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { User } from '../users/entities/user.entity';
import { Occupation } from '../occupation/entities/occupation.entity';

@Injectable()
export class NotificationService {
  constructor(
    @InjectRepository(Notification)
    private notificationRepository: Repository<Notification>,
  ) {}

  // Método interno — lo usan otros servicios
  async notify(dto: CreateNotificationDto) {
    const notification = this.notificationRepository.create({
      userId: dto.userId,
      type: dto.type,
      title: dto.title,
      body: dto.body,
      entityType: dto.entityType,
      entityId: dto.entityId,
      adminSenderId: dto.adminSenderId,
      data: dto.data,
      isRead: false,
    });

    return this.notificationRepository.save(notification);
  }

  async findMyNotifications(userId: string) {
    return this.notificationRepository.find({
      where: { userId },
      order: { creationDate: 'DESC' },
    });
  }

  // Notificaciones enriquecidas con datos del solicitante y del service_request
  // para alimentar las cards del frontend sin N+1 queries.
  async findMyNotificationsEnriched(userId: string) {
    // Notificaciones estándar (service_request, propuesta aceptada, etc.)
    const standardRows = await this.notificationRepository
      .createQueryBuilder('n')
      .leftJoin(ServiceRequest, 'sr', 'sr.id::text = n.entity_id')
      .leftJoin(User, 'requester', 'requester.id = sr.user_id')
      .leftJoin(Occupation, 'occ', 'occ.id = sr.occupation_id')
      .select([
        'n.id AS id',
        'n.user_id AS "userId"',
        'n.type AS type',
        'n.title AS title',
        'n.body AS body',
        'n.entity_type AS "entityType"',
        'n.entity_id AS "entityId"',
        'n.is_read AS "isRead"',
        'n.creation_date AS "creationDate"',
        'sr.description AS "srDescription"',
        'sr.direction AS "srDirection"',
        'occ.name AS "occupationName"',
        'requester.id AS "requesterId"',
        'requester.name AS "requesterName"',
        'requester.last_name AS "requesterLastName"',
        'requester.image_profile AS "requesterImage"',
      ])
      .where('n.user_id = :userId', { userId })
      .andWhere(`n.type <> :proposalType`, { proposalType: 'proposal_received' })
      .orderBy('n.creation_date', 'DESC')
      .getRawMany();

    // Notificaciones de propuesta recibida — la entity_id apunta a la propuesta
    const proposalRows = await this.notificationRepository
      .createQueryBuilder('n')
      .leftJoin(Proposal, 'p', 'p.id::text = n.entity_id')
      .leftJoin(ServiceRequest, 'sr', 'sr.id = p.service_request_id')
      .leftJoin(Occupation, 'occ', 'occ.id = sr.occupation_id')
      .leftJoin(User, 'requester', 'requester.id = sr.user_id')
      .leftJoin(ProfileColab, 'pc', 'pc.id = p.profile_colab_id')
      .leftJoin(User, 'colab', 'colab.id = pc.user_id')
      .select([
        'n.id AS id',
        'n.user_id AS "userId"',
        'n.type AS type',
        'n.title AS title',
        'n.body AS body',
        'n.entity_type AS "entityType"',
        'n.entity_id AS "entityId"',
        'n.is_read AS "isRead"',
        'n.creation_date AS "creationDate"',
        'n.data AS data',
        'sr.id AS "srId"',
        'sr.description AS "srDescription"',
        'sr.direction AS "srDirection"',
        'occ.name AS "occupationName"',
        'requester.id AS "requesterId"',
        'requester.name AS "requesterName"',
        'requester.last_name AS "requesterLastName"',
        'requester.image_profile AS "requesterImage"',
        'p.amount AS "proposalAmount"',
        'colab.id AS "colabId"',
        'colab.name AS "colabName"',
        'colab.last_name AS "colabLastName"',
        'colab.image_profile AS "colabImage"',
      ])
      .where('n.user_id = :userId', { userId })
      .andWhere('n.type = :proposalType', { proposalType: 'proposal_received' })
      .orderBy('n.creation_date', 'DESC')
      .getRawMany();

    const mapStandard = (row: any) => ({
      id: row.id,
      userId: row.userId,
      type: row.type,
      title: row.title,
      body: row.body,
      entityType: row.entityType,
      entityId: row.entityId,
      isRead: row.isRead,
      creationDate: row.creationDate,
      serviceRequest: {
        id: row.entityId,
        description: row.srDescription,
        direction: row.srDirection,
        occupationName: row.occupationName,
      },
      requester: {
        id: row.requesterId,
        name: row.requesterName,
        lastName: row.requesterLastName,
        imageProfile: row.requesterImage,
      },
      proposal: null,
    });

    const mapProposal = (row: any) => {
      const raw = typeof row.data === 'string' ? JSON.parse(row.data) : (row.data ?? {});
      const hasColab = row.colabId != null && row.colabName != null;
      const hasAmount = row.proposalAmount != null;
      return {
        id: row.id,
        userId: row.userId,
        type: row.type,
        title: row.title,
        body: row.body,
        entityType: row.entityType,
        entityId: row.entityId,
        isRead: row.isRead,
        creationDate: row.creationDate,
        serviceRequest: {
          id: row.srId ?? row.entityId,
          description: row.srDescription,
          direction: row.srDirection,
          occupationName: row.occupationName,
        },
        requester: {
          id: row.requesterId,
          name: row.requesterName,
          lastName: row.requesterLastName,
          imageProfile: row.requesterImage,
        },
        proposal: hasColab || hasAmount
          ? {
              amount: row.proposalAmount != null ? Number(row.proposalAmount) : null,
              distanceKm: raw.distanceKm ?? null,
              colab: {
                id: row.colabId,
                name: row.colabName,
                lastName: row.colabLastName,
                imageProfile: row.colabImage,
              },
            }
          : null,
      };
    };

    const merged = [
      ...standardRows.map(mapStandard),
      ...proposalRows.map(mapProposal),
    ];

    return merged.sort((a, b) =>
      new Date(b.creationDate).getTime() - new Date(a.creationDate).getTime(),
    );
  }

  async markAsRead(id: string, userId: string) {
    const notification = await this.notificationRepository.findOne({
      where: { id, userId },
    });

    if (!notification) return null;

    notification.isRead = true;
    return this.notificationRepository.save(notification);
  }

  async markAllAsRead(userId: string) {
    await this.notificationRepository
      .createQueryBuilder()
      .update(Notification)
      .set({ isRead: true })
      .where('userId = :userId', { userId })
      .andWhere('isRead = false')
      .execute();

    return { message: 'Todas las notificaciones marcadas como leídas' };
  }

  async remove(id: string, userId: string) {
    const notification = await this.notificationRepository.findOne({
      where: { id, userId },
    });

    if (!notification) return null;

    return this.notificationRepository.remove(notification);
  }
}