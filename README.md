# Colabs
 
Aplicación móvil SaaS que conecta usuarios que ofrecen servicios empíricos (carpintero, electricista, gasfitero, etc.) con usuarios que los buscan.
 
---
 
## Inspiración
 
| Referente | Elemento adoptado |
|---|---|
| LinkedIn | Perfil profesional del colaborador |
| Facebook Marketplace | Publicación y oferta de servicios |
| Instagram | Feed de posts del colaborador |
| InDriver | Solicitud de servicio por ubicación |
 
---
 
## Roles de usuario
 
- **Demandante** — todo usuario al registrarse. Busca y contrata servicios.
- **Colaborador** — demandante que activa su perfil profesional mediante el botón "Conviértete en colaborador". No hay campo `role` en la base de datos — la existencia de `profile_colab` define el rol.
- **Admin** — equipo interno de Colabs. Tabla separada `admin_users`, nunca se mezcla con `users`.
Un colaborador también puede solicitar servicios de otro colaborador.
 
---
 
## Tres flujos principales de servicio
 
### Flujo A — Solicitud tipo InDriver (fundamental)
1. Usuario abre el mapa y mueve el pin a donde necesita el servicio.
2. Selecciona la ocupación requerida y envía la solicitud.
3. La solicitud llega a colaboradores disponibles en un radio de 5 km que ofrezcan esa ocupación.
4. Los colaboradores envían propuestas con su precio.
5. El usuario acepta la mejor oferta.
### Flujo B — Consulta desde un post
1. Usuario ve un post de un colaborador en el feed.
2. Toca "Consultar" y se abre un chat guiado.
3. Coordinan libremente (descripción, fotos, preguntas).
4. El colaborador hace una oferta formal dentro del chat.
5. Al aceptar la oferta, el sistema genera automáticamente un `service_request`.
### Flujo C — Re-solicitar desde historial
1. Usuario va a su historial de servicios anteriores.
2. Selecciona un trabajo pasado y toca "Volver a solicitar".
3. Se pre-rellena el formulario con el colaborador y la ocupación anterior.
4. Se crea un nuevo `service_request` normal.
---
 
## Stack técnico
 
| Capa | Tecnología |
|---|---|
| Frontend móvil | Flutter |
| Manejo de estado | BLoC |
| Backend | NestJS (módulos nativos) |
| Base de datos principal | PostgreSQL + JSONB + PostGIS |
| Ubicación efímera | Redis (TTL 60s, nunca toca PostgreSQL) |
| Almacenamiento de media | Cloudinary |
| Autenticación | Passport.js + JWT |
| Contenedores | Docker + Docker Compose |
| Reverse proxy | Nginx + SSL (Let's Encrypt) |
| Hosting | DigitalOcean Droplet |
| Control de versiones | GitHub (repositorio privado) |
 
---
 
## Arquitectura de infraestructura
 
```
DigitalOcean Droplet (Ubuntu 22.04)
│
└── Docker Compose
     ├── nginx          → reverse proxy, puerto 80/443
     ├── nestjs         → API, puerto 3000 (interno)
     ├── postgresql     → BD, puerto 5432 (interno)
     └── redis          → cache de ubicaciones, puerto 6379 (interno)
 
Flutter (desarrollo local, fuera de Docker)
   ↕ HTTPS
Nginx → NestJS → PostgreSQL / Redis
              → Cloudinary (externo)
```
 
---
 
## Requisitos previos
 
### Si usas WSL2 (recomendado en Linux/Windows)
- WSL2 instalado con Ubuntu 22.04
- Docker Desktop con integración WSL2 activada
- VS Code con extensión Remote - WSL
- Node.js 20+ dentro de WSL2
- Yarn instalado globalmente: `npm install -g yarn`
- NestJS CLI: `npm install -g @nestjs/cli`
### Si usas Windows puro
- Docker Desktop for Windows
- Git for Windows
- VS Code
- Node.js 20+ para Windows
- Yarn: `npm install -g yarn`
- NestJS CLI: `npm install -g @nestjs/cli`
---
 
## Levantar el proyecto en local
 
### 1. Clonar el repositorio
 
```bash
git clone https://github.com/tu-usuario/colabs.git
cd colabs
```
 
### 2. Crear el archivo de variables de entorno
 
```bash
cp .env.example .env
```
 
Edita el `.env` y completa los valores necesarios (ver sección Variables de entorno).
 
### 3. Levantar los contenedores
 
```bash
docker compose up -d
```
 
Esto levanta PostgreSQL + PostGIS, Redis, NestJS y Nginx automáticamente.
 
### 4. Verificar que todo está corriendo
 
```bash
docker compose ps
```
 
Deberías ver todos los servicios con estado `running`.
 
### 5. Verificar la API
 
```
http://localhost:8080/api        → API principal
http://localhost:8080/docs       → Swagger (documentación)
http://localhost:5051            → pgAdmin (administrador de BD)
```
 
### Comandos útiles
 
```bash
# Ver logs de todos los servicios
docker compose logs -f
 
# Ver logs solo del backend
docker compose logs -f backend
 
# Reiniciar solo el backend
docker compose restart backend
 
# Detener todo
docker compose down
 
# Detener y eliminar volúmenes (resetea la BD)
docker compose down -v
```
 
---
 
## Estructura del repositorio
 
```
colabs/
├── colabs-backend/          → API NestJS
│   ├── src/
│   │   ├── modules/         → módulos del negocio
│   │   │   ├── auth/
│   │   │   ├── users/
│   │   │   ├── profile-colab/
│   │   │   ├── occupation/
│   │   │   ├── service-request/
│   │   │   ├── proposal/
│   │   │   ├── conversation/
│   │   │   ├── message/
│   │   │   ├── post/
│   │   │   ├── notification/
│   │   │   ├── report/
│   │   │   ├── suggestion/
│   │   │   └── support/
│   │   ├── common/          → código reutilizable
│   │   │   ├── decorators/
│   │   │   ├── filters/
│   │   │   ├── guards/
│   │   │   ├── interceptors/
│   │   │   ├── interfaces/
│   │   │   └── pipes/
│   │   ├── config/          → configuración centralizada
│   │   │   ├── database.config.ts
│   │   │   ├── redis.config.ts
│   │   │   └── jwt.config.ts
│   │   ├── database/
│   │   │   ├── migrations/  → cambios de esquema versionados
│   │   │   └── seeds/       → datos iniciales
│   │   ├── app.module.ts
│   │   └── main.ts
│   ├── Dockerfile
│   └── package.json
├── colabs-frontend/         → App Flutter (próximamente)
├── nginx/
│   └── nginx.conf
├── docker-compose.yml
├── .env.example             → plantilla de variables (sí va en git)
├── .env                     → variables reales (NO va en git)
├── .gitignore
└── README.md
```
 
### Estructura interna de cada módulo
 
```
modules/auth/
├── dto/                     → forma de los datos que entran (request)
│   ├── login.dto.ts
│   └── register.dto.ts
├── entities/                → definición de tablas (TypeORM)
│   └── user-provider.entity.ts
├── auth.module.ts           → declara e importa todo lo del módulo
├── auth.controller.ts       → define los endpoints (rutas HTTP)
└── auth.service.ts          → lógica de negocio
```
 
---
 
## Autenticación
 
- Email + contraseña (provider: `local`)
- Google OAuth 2.0
- Facebook OAuth 2.0
- Apple Sign In
Todos los providers se almacenan en la tabla `user_providers`. Un usuario puede tener múltiples providers vinculados a la misma cuenta.
 
Flujo OAuth 2.0:
```
Flutter → abre navegador del proveedor
       ← recibe authorization_code
Flutter → envía code al backend NestJS
NestJS  → valida con el proveedor
        → busca o crea usuario en PostgreSQL
        → emite JWT propio de Colabs
Flutter ← recibe JWT → lo guarda localmente
        → usa JWT en todas las requests
```
 
---
 
## Modelo de datos
 
### Módulo — Usuarios y autenticación
 
**`users`**
| Campo | Tipo |
|---|---|
| id | uuid PK |
| email | string |
| name | string |
| last_name | string |
| phone_number | string |
| image_profile | string |
| date_birth | date |
| gender | string |
| registration_date | timestamp |
| status | string |
 
**`user_providers`**
| Campo | Tipo |
|---|---|
| id | uuid PK |
| user_id | uuid FK → users |
| provider | string (`local` \| `google` \| `facebook` \| `apple`) |
| provider_id | string (nullable) |
| password_hash | string (nullable) |
 
**`admin_users`**
| Campo | Tipo |
|---|---|
| id | uuid PK |
| name | string |
| email | string |
| password_hash | string |
| role_admin | string (`super_admin` \| `moderator`) |
| created_at | timestamp |
| status | string |
 
---
 
### Módulo — Colaborador y servicios
 
**`profile_colab`**
| Campo | Tipo |
|---|---|
| id | uuid PK |
| user_id | uuid FK → users |
| description | string |
| experience | string |
| dni | string |
| verification_status | string |
| status | string |
 
**`occupation`** — catálogo de oficios definido por Colabs
| Campo | Tipo |
|---|---|
| id | uuid PK |
| name | string |
| image | string |
| status | string |
 
**`profile_colab_occupations`** — tabla intermedia M a M
| Campo | Tipo |
|---|---|
| profile_colab_id | uuid FK → profile_colab |
| occupation_id | uuid FK → occupation |
 
**`service_request`**
| Campo | Tipo |
|---|---|
| id | uuid PK |
| user_id | uuid FK → users |
| occupation_id | uuid FK → occupation |
| location | geography(POINT, 4326) — PostGIS |
| direction | string (dirección legible en texto) |
| description | string |
| creation_date | timestamp |
| acceptance_date | timestamp |
| completion_date | timestamp |
| status | string (`pending` \| `accepted` \| `in_progress` \| `completed` \| `cancelled` \| `disputed`) |
 
**`proposal`**
| Campo | Tipo |
|---|---|
| id | uuid PK |
| profile_colab_id | uuid FK → profile_colab |
| service_request_id | uuid FK → service_request |
| amount | decimal |
| status | string |
 
**`comment_request`** — 1 a 1 con service_request
| Campo | Tipo |
|---|---|
| id | uuid PK |
| user_id | uuid FK → users |
| service_request_id | uuid FK → service_request |
| comment | string |
| rating | int |
| creation_date | timestamp |
| status | string |
 
---
 
### Módulo — Chat
 
**`conversation`**
| Campo | Tipo |
|---|---|
| id | uuid PK |
| user_id | uuid FK → users |
| profile_colab_id | uuid FK → profile_colab |
| post_id | uuid FK → post (nullable) |
| service_request_id | uuid FK → service_request (nullable) |
| status | string (`pending` \| `open` \| `offer_sent` \| `accepted` \| `closed` \| `expired`) |
| expires_at | timestamp (nullable — 24h desde que colaborador queda libre) |
| created_at | timestamp |
 
**`message`**
| Campo | Tipo |
|---|---|
| id | uuid PK |
| conversation_id | uuid FK → conversation |
| sender_id | uuid FK → users |
| content | string |
| type | string (`text` \| `offer` \| `system`) |
| amount | decimal (nullable — solo si type = `offer`) |
| is_read | boolean |
| created_at | timestamp |
 
---
 
### Módulo — Feed social
 
**`post`**
| Campo | Tipo |
|---|---|
| id | uuid PK |
| profile_colab_id | uuid FK → profile_colab |
| description | string |
| media | jsonb (array de URLs de Cloudinary) |
| creation_date | timestamp |
| status | string |
 
**`post_like`** — PK compuesta
| Campo | Tipo |
|---|---|
| user_id | uuid FK → users |
| post_id | uuid FK → post |
| created_at | timestamp |
 
**`post_comment`**
| Campo | Tipo |
|---|---|
| id | uuid PK |
| user_id | uuid FK → users |
| post_id | uuid FK → post |
| comment | string |
| creation_date | timestamp |
 
**`user_follows`** — PK compuesta, auto-relación
| Campo | Tipo |
|---|---|
| follower_id | uuid FK → users |
| following_id | uuid FK → users |
| created_at | timestamp |
 
---
 
### Módulo — Notificaciones y soporte
 
**`notification`**
| Campo | Tipo |
|---|---|
| id | uuid PK |
| user_id | uuid FK → users |
| admin_sender_id | uuid FK → admin_users (nullable) |
| type | string |
| title | string |
| body | string |
| entity_type | string (`service_request` \| `proposal` \| `post` \| `profile_colab` \| null) |
| entity_id | uuid (nullable — polimórfico, no FK formal) |
| is_read | boolean |
| creation_date | timestamp |
 
**`report`**
| Campo | Tipo |
|---|---|
| id | uuid PK |
| reporter_id | uuid FK → users |
| reported_user_id | uuid FK → users |
| service_request_id | uuid FK → service_request (nullable) |
| admin_user_id | uuid FK → admin_users (nullable) |
| category | string |
| date | timestamp |
| status | string |
 
**`suggestion`**
| Campo | Tipo |
|---|---|
| id | uuid PK |
| user_id | uuid FK → users |
| admin_user_id | uuid FK → admin_users (nullable) |
| description | string |
| date | timestamp |
| status | string |
 
**`support`**
| Campo | Tipo |
|---|---|
| id | uuid PK |
| user_id | uuid FK → users |
| admin_user_id | uuid FK → admin_users (nullable) |
| description | string |
| date | timestamp |
| status | string |
 
---
 
## Redis — ubicación de colaboradores
 
La ubicación del colaborador nunca toca PostgreSQL. Se almacena en Redis con TTL de 60 segundos.
 
```json
{
  "lat": -12.046,
  "lng": -77.042,
  "occupation": "Electricidad",
  "status": "available"
}
```
 
Estados: `available` | `busy`
 
- `available` → aparece en búsquedas del Flujo A y recibe chats
- `busy` → no aparece en búsquedas del Flujo A, sí recibe consultas de chat
---
 
## Variables de entorno
 
Copia `.env.example` a `.env` y completa los valores:
 
```env
# Base de datos
DATABASE_USER=
DATABASE_PASSWORD=
DATABASE_DB=colabs
 
# Backend
BACKEND_PORT=3000
NODE_ENV=development
 
# pgAdmin
PGADMIN_EMAIL=
PGADMIN_PASSWORD=
 
# JWT
JWT_SECRET=
JWT_EXPIRES_IN=7d
 
# Redis
REDIS_HOST=redis
REDIS_PORT=6379
 
# OAuth — Google
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_CALLBACK_URL=
 
# OAuth — Facebook
FACEBOOK_APP_ID=
FACEBOOK_APP_SECRET=
FACEBOOK_CALLBACK_URL=
 
# Cloudinary
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=
```
 
---
 
## Dependencias del backend (NestJS)
 
```bash
# Core
@nestjs/common @nestjs/core @nestjs/platform-express
 
# Base de datos
@nestjs/typeorm typeorm pg @nestjs/config
 
# Autenticación
@nestjs/passport @nestjs/jwt passport passport-local
passport-jwt passport-google-oauth20 passport-facebook bcrypt
 
# Validación
class-validator class-transformer
 
# Redis
ioredis @nestjs/cache-manager cache-manager-ioredis
 
# WebSockets
@nestjs/websockets @nestjs/platform-socket.io socket.io
 
# Documentación
@nestjs/swagger swagger-ui-express
 
# Utilidades
uuid
```
 
---
 
## Dependencias del frontend (Flutter)
 
```yaml
flutter_bloc: ^8.0.0
equatable: ^2.0.0
dio: ^5.0.0
google_sign_in: ^6.0.0
flutter_facebook_auth: ^6.0.0
sign_in_with_apple: ^5.0.0
flutter_secure_storage: ^9.0.0
shared_preferences: ^2.0.0
google_maps_flutter: ^2.0.0
geolocator: ^10.0.0
geocoding: ^2.0.0
image_picker: ^1.0.0
socket_io_client: ^2.0.0
intl: ^0.18.0
uuid: ^4.0.0
```
 
---
 
## Decisiones de arquitectura
 
- **Sin Clean Architecture por ahora** — módulos nativos de NestJS. Se evalúa migrar cuando el proyecto lo justifique.
- **Sin Firebase** — autenticación, storage y base de datos son completamente independientes de Firebase.
- **Cloudinary** para almacenamiento y transformación de imágenes.
- **PostgreSQL en contenedor Docker** para desarrollo. Se evalúa managed database en producción.
- **Tracking visual de ruta** — se implementa en versión posterior. Primera versión solo muestra estados.
- **Panel de administración** — se construye después de la app móvil.
---
 
## Estado del proyecto
 
- [x] Definición del producto y casos de uso
- [x] Diseño UI en Figma
- [x] Modelo de datos v2.0
- [x] Decisiones de stack y arquitectura
- [x] Repositorio GitHub configurado
- [x] Docker Compose + Dockerfile + Nginx
- [x] Estructura de carpetas NestJS
- [ ] Instalar dependencias NestJS
- [ ] Configurar TypeORM y conexión a BD
- [ ] Módulo de autenticación
- [ ] Resto de módulos del negocio
- [ ] App Flutter
- [ ] Panel de administración
 