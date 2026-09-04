import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Notification } from './entities/notification.entity';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { ServiceRequest } from '../service-request/entities/service-request.entity';
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
    const rows = await this.notificationRepository
      .createQueryBuilder('n')
      .leftJoin(ServiceRequest, 'sr', 'sr.id::text = n.entity_id')
      .leftJoin(User, 'requester', 'requester.id = sr.user_id')
      .leftJoin(Occupation, 'occ', 'occ.id = sr.occupation_id')
      .leftJoin(User, 'colab', 'colab.id = n.user_id')
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
      .orderBy('n.creation_date', 'DESC')
      .getRawMany();

    return rows.map(row => ({
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
    }));
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