import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { UseGuards } from '@nestjs/common';
import { RedisService } from '../../common/services/redis.service';

@WebSocketGateway({
  cors: { origin: '*' }, // permite conexiones desde cualquier origen (ajustar en producción)
  namespace: '/colabs', // namespace para separar de otros posibles WebSockets en la app
})
// el servidor WebSocket de NestJS se encargará de manejar las conexiones de los colaboradores
export class CollabsGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server!: Server;

  // Mapa de userId → socketId para saber a quién emitir
  // directorio de quién está conectado 
  private connectedUsers = new Map<string, string>();

  constructor(private redisService: RedisService) {}

  handleConnection(client: Socket) {
    console.log(`Cliente conectado: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    // Eliminar de connectedUsers cuando se desconecta
    for (const [userId, socketId] of this.connectedUsers.entries()) {
      if (socketId === client.id) {
        this.connectedUsers.delete(userId);
        this.redisService.removeCollaboratorLocation(userId);
        console.log(`Colaborador ${userId} desconectado — eliminado de Redis`);
        break;
      }
    }
  }

  // Flutter llama esto para registrarse con su userId
  // "hola soy el usuario X, guárdame" y así el backend sabe a quién emitir cuando hay una nueva solicitud de servicio
  @SubscribeMessage('register')
  handleRegister(
    @MessageBody() data: { userId: string },
    @ConnectedSocket() client: Socket,
  ) {
    this.connectedUsers.set(data.userId, client.id);
    console.log(`Usuario ${data.userId} registrado con socket ${client.id}`);
  }

  // Colaborador actualiza su ubicación
  // hola soy el usuario X, esta es mi ubicación y mis ocupaciones, guárdame en Redis con TTL para que sepa que estoy disponible
  @SubscribeMessage('update_location')
  async handleUpdateLocation(
    @MessageBody() data: { userId: string; lat: number; lng: number; occupationIds: string[] },
    @ConnectedSocket() client: Socket,
  ) {
    await this.redisService.setCollaboratorLocation(
      data.userId,
      data.lat,
      data.lng,
      data.occupationIds,
    );
  }

  // Emitir nueva solicitud a colaboradores cercanos
  // el backend llama esto cuando se crea una nueva solicitud de servicio, y le dice a Redis "oye Redis, dame los colaboradores cercanos a esta ubicación que tengan esta ocupación", y luego emite la solicitud a esos colaboradores
  emitNewServiceRequest(
    collaboratorIds: string[],
    serviceRequest: any,
  ) {
    for (const userId of collaboratorIds) {
      const socketId = this.connectedUsers.get(userId);
      if (socketId) {
        this.server.to(socketId).emit('new_service_request', serviceRequest);
      }
    }
  }
}