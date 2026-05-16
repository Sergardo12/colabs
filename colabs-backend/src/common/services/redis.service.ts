import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';

@Injectable()
export class RedisService implements OnModuleInit, OnModuleDestroy {
  private client!: Redis;

  constructor(private configService: ConfigService) {}

  onModuleInit() {
    this.client = new Redis({
      host: this.configService.get<string>('redis.host'),
      port: this.configService.get<number>('redis.port'),
    });
  }

  onModuleDestroy() {
    this.client.disconnect();
  }

  // Guarda ubicación del colaborador con TTL
  async setCollaboratorLocation(
    userId: string,
    lat: number,
    lng: number,
    occupationIds: string[],
    ttl: number = 60,
  ) {
    const key = `colab:${userId}`;
    const value = JSON.stringify({
      lat,
      lng,
      occupationIds,
      status: 'available',
    });
    await this.client.setex(key, ttl, value);
  }

  // Actualiza el status del colaborador
  async setCollaboratorStatus(userId: string, status: 'available' | 'busy') {
    const key = `colab:${userId}`;
    const existing = await this.client.get(key);
    if (!existing) return;

    const data = JSON.parse(existing);
    data.status = status;
    const ttl = await this.client.ttl(key);
    await this.client.setex(key, ttl, JSON.stringify(data));
  }

  // Elimina la ubicación del colaborador
  async removeCollaboratorLocation(userId: string) {
    await this.client.del(`colab:${userId}`);
  }

  // Busca colaboradores cercanos por occupation
  async findNearbyCollaborators(occupationId: string): Promise<Array<{
    userId: string;
    lat: number;
    lng: number;
  }>> {
    const keys = await this.client.keys('colab:*');

    const collaborators: Array<{   
    userId: string;
    lat: number;
    lng: number;
    }> = [];

    for (const key of keys) {
      const value = await this.client.get(key);
      if (!value) continue;

      const data = JSON.parse(value);
      if (
        data.status === 'available' &&
        data.occupationIds.includes(occupationId)
      ) {
        const userId = key.replace('colab:', '');
        collaborators.push({ userId, lat: data.lat, lng: data.lng });
      }
    }

    return collaborators;
  }

  // Obtiene ubicación de un colaborador
  async getCollaboratorLocation(userId: string) {
    const value = await this.client.get(`colab:${userId}`);
    if (!value) return null;
    return JSON.parse(value);
  }
}