# Colabs
 
Aplicación móvil SaaS que conecta usuarios que ofrecen servicios empíricos (carpintero, electricista, gasfitero, etc.) con usuarios que los buscan.
 
---

## 📊 Progreso del proyecto

**🚀 Lanzamiento objetivo: 27 de diciembre de 2026**
**🧪 Pruebas con usuarios reales: 1 — 20 de diciembre de 2026**

### Backend (NestJS)
![Backend Progress](https://progress-bar.xyz/87/?title=Backend&width=500&color=1E41BC)
`13 de 15 módulos completados`

### Frontend (Flutter)
![Frontend Progress](https://progress-bar.xyz/72/?title=Flutter&width=500&color=017DB0)
`19 de 26 funcionalidades completadas`

### Flujos principales
| Flujo | Estado | Descripción |
|---|---|---|
| Flujo A — Solicitud InDriver | 🔴 Pendiente | Usuario solicita por ubicación, colaboradores proponen |
| Flujo B — Consulta desde post | 🟢 Completo | Usuario consulta desde feed, chat con oferta y aceptación |
| Flujo C — Re-solicitar desde historial | 🔴 Pendiente | Re-solicitar servicio anterior |

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
├── colabs_frontend/         → App Flutter (Flutter + BloC)
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

### Estructura del frontend (Flutter)

```
colabs_frontend/
├── lib/
│ ├── main.dart → entrada de la app, inyección de dependencias
│ ├── app.dart → MaterialApp, tema y rutas
│ ├── core/ → código transversal
│ │ ├── constants/ → colores, textos, tamaños
│ │ ├── network/ → cliente Dio (sin interceptors aún)
│ │ ├── routes/ → 8 rutas nombradas en app_router.dart
│ │ ├── storage/ → pendiente: wrapper de secure storage
│ │ └── theme/ → tema global Material
│ ├── features/ → módulos del negocio
│ │ ├── splash/ → verificación JWT con /auth/me
│ │ ├── auth/ → login, register, Google Sign In
│ │ ├── home/ → shell, bottom nav, feed, carrusel ocupaciones
│ │ ├── profile/ → drawer, perfil, become colab, edit colab
│ │ ├── search/ → búsqueda de colaboradores con paginación
│ │ ├── feed/ → pendiente
│ │ ├── chat/ → pendiente
│ │ └── service_request/ → pendiente
│ └── shared/
│ └── widgets/ → widgets reutilizables globales
├── assets/
│ ├── images/ → slides del carrusel welcome
│ └── icons/ → logos de Google y Apple
├── test/
└── pubspec.yaml
```

### Estructura interna de cada feature (Flutter)

```
features/auth/
├── bloc/                        → AuthBloc, AuthEvent, AuthState
├── data/                        → llamadas HTTP y repositorio
├── models/                      → JSON → objeto Dart
└── pages/                       → pantallas y widgets del módulo
```

Nota: feed/, chat/ y service_request/ contienen solo stubs vacíos.
Se implementan en próximas iteraciones.
---
 
## Autenticación
 
- Email + contraseña (provider: `local`)
- Google OAuth 2.0 (mobile — implementado)
- Facebook OAuth 2.0 (pendiente)
- Apple Sign In (pendiente)
Todos los providers se almacenan en la tabla `user_providers`. Un usuario puede tener múltiples providers vinculados a la misma cuenta.

Flujo Google OAuth — Mobile (implementado)

```
Flutter → google_sign_in SDK → obtiene idToken de Google
Flutter → POST /api/auth/google/mobile con idToken
NestJS  → valida idToken con Google OAuth2Client
        → busca o crea usuario en PostgreSQL
        → emite JWT propio de Colabs
Flutter ← recibe JWT → lo guarda en FlutterSecureStorage
        → usa JWT en todas las requests
```

Flujo local — Email/Contraseña (implementado)

```
Flutter → POST /api/auth/login con email y password
NestJS  → valida credenciales → emite JWT
Flutter ← recibe JWT → lo guarda en FlutterSecureStorage
```

Providers pendientes: Facebook, Apple
 
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
| dni_image | string (nullable) |
| certifications | string (nullable) |
| profile_video | string (nullable — reservado V2) |
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
| price | decimal (nullable — precio referencial) |
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
  "occupationIds": ["uuid-occupation-1"],
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

## Seeds — datos iniciales

Ejecutar una vez después de levantar los contenedores:

```bash
docker exec -it colabs_backend yarn seed
```

Inserta las 20 ocupaciones iniciales del catálogo. Es idempotente — seguro correrlo múltiples veces.

**Ocupaciones incluidas:**
Electricidad, Gasfitería, Carpintería, Albañilería, Pintura, Jardinería, Cerrajería, Fumigación, Limpieza del hogar, Mudanza, Refrigeración y AC, Techado, Soldadura, Mecánica, Electrónica, Repostería, Costura y Confección, Fotografía, Clases particulares.

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
# Instaladas actualmente
flutter_bloc: ^8.1.6
equatable: ^2.0.5
dio: ^5.7.0
flutter_secure_storage: ^9.2.2
smooth_page_indicator: ^1.2.0+3
google_sign_in: ^6.2.2

# Pendientes de instalar cuando se implemente el módulo
# google_maps_flutter, geolocator, geocoding → mapa y ubicación
# socket_io_client → chat en tiempo real
# image_picker → subida de imágenes
# flutter_facebook_auth, sign_in_with_apple → auth social pendiente
# shared_preferences, intl, uuid → utilidades generales
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

### Backend (NestJS)
- [x] Definición del producto y casos de uso
- [x] Modelo de datos v2.0
- [x] Decisiones de stack y arquitectura
- [x] Repositorio GitHub configurado
- [x] Docker Compose + Dockerfile + Nginx
- [x] Estructura de carpetas NestJS
- [x] Módulo de autenticación (local + Google OAuth mobile)
- [x] Módulo de usuarios
- [x] Módulo de perfil colaborador (CRUD + búsqueda con query)
- [x] Módulo de ocupaciones
- [x] Módulo de posts y feed
- [x] Módulo de conversaciones y mensajes
- [x] Módulo de service request y propuestas
- [ ] Módulo de notificaciones
- [ ] Panel de administración

### Frontend (Flutter)
- [x] Entorno Flutter configurado (Windows + emulador Android)
- [x] Estructura de carpetas por features
- [x] Core — colores, tema, rutas, cliente HTTP
- [x] Splash screen con verificación JWT real (/auth/me)
- [x] Welcome screen con carrusel auto-scroll (3 slides)
- [x] Login con email/contraseña conectado al backend
- [x] Register completo conectado al backend
- [x] Google Sign In mobile
- [x] AuthBloc completo con manejo de errores
- [x] Home shell con bottom nav (5 tabs)
- [x] Feed de posts con paginación e infinite scroll
- [x] Carrusel de ocupaciones en home
- [x] Drawer con info del usuario
- [x] Página de perfil (básico y colaborador)
- [x] Flujo "Convertirse en colaborador" con selector de ocupaciones
- [x] Edición de perfil de colaborador
- [x] Búsqueda de colaboradores con paginación y filtro query
- [x] Pantalla "Mis solicitudes" con estados y link a chat
- [x] Chat en tiempo real (WebSocket + Socket.io)
- [x] Flujo B completo — consulta desde post, oferta y aceptación
- [x] Lista de conversaciones con interlocutor correcto
- [x] Burbujas de mensaje estilo WhatsApp
- [ ] Botón central — solicitud tipo InDriver
- [ ] Historial de servicios
- [ ] Favoritos
- [ ] Notificaciones
- [x] Vista pública de colaborador
- [ ] Subida de imágenes (Cloudinary)
- [ ] Panel de administración

---

## 🔧 Deuda técnica conocida

| Issue | Impacto | Prioridad |
|---|---|---|
| Zona horaria en mensajes del chat | Visual — hora incorrecta en dev local | Media |
| WebSocket persistente en chat | Performance — reconecta por cada conversación | Media |
| currentUserId via ProfileBloc en router | Frágil si perfil no cargado | Baja |
| withOpacity deprecado (~45 usos) | Warning de lint | Baja |

---

## Flujo de trabajo Git

Usamos **GitHub Flow** adaptado con rama `develop` como integración.

### Ramas

| Rama | Propósito |
|---|---|
| `main` | Código en producción. Nadie pushea directo aquí. |
| `develop` | Integración. Aquí se unen todos los cambios probados. |
| `feature/xxx` | Una rama por funcionalidad. Sale de develop, vuelve a develop. |
| `fix/xxx` | Corrección de bugs. Sale de develop. |
| `hotfix/xxx` | Bugs críticos en producción. Sale de main. |

### Convención de nombres de ramas
feature/auth-login
feature/user-registration
fix/jwt-expiration
hotfix/critical-login-error
docs/update-readme
chore/install-dependencies

### Conventional Commits

Todo commit debe seguir este formato:
tipo(alcance): descripción corta en minúsculas

| Tipo | Cuándo usarlo |
|---|---|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `chore` | Dependencias, configuración |
| `docs` | Documentación |
| `refactor` | Reorganizar sin cambiar funcionalidad |
| `test` | Agregar o corregir tests |
| `style` | Formato, espacios, punto y coma |

Ejemplos correctos:
feat(auth): add google oauth login
fix(auth): resolve jwt token expiration issue
chore(deps): install typeorm and pg
docs(readme): add git workflow section

### Flujo día a día

**1. Antes de empezar cualquier tarea — siempre desde develop actualizado:**
```bash
git checkout develop
git pull origin develop
git checkout -b feature/nombre-de-la-tarea
```

**2. Mientras trabajas — commits pequeños y frecuentes:**
```bash
git add .
git commit -m "feat(auth): add jwt token generation"
```

**3. Cuando terminas — sube tu rama y abre un Pull Request:**
```bash
git push origin feature/nombre-de-la-tarea
```

**4. Después del merge — limpia tu rama local:**
```bash
git checkout develop
git pull origin develop
git branch -d feature/nombre-de-la-tarea
```
---

### Sincronizar tu rama cuando otros mergean PRs

Si estás trabajando en tu rama y un compañero mergeó un PR a `develop`:

**1. Guarda tus cambios actuales:**
```bash
git add .
git commit -m "feat(x): work in progress"
```

**2. Baja los cambios remotos sin aplicarlos:**
```bash
git fetch origin
```

**3. Reescribe tu rama encima del develop actualizado:**
```bash
git rebase origin/develop
```

**4. Si hay conflictos — resuélvelos y continúa:**
```bash
# Abre el archivo en conflicto, resuelve manualmente y luego:
git add archivo-con-conflicto.ts
git rebase --continue
```

**5. Sube tu rama actualizada:**
```bash
git push origin feat/tu-rama --force
```

> ⚠️ El `--force` es necesario después de un rebase porque reescribiste el historial.
> Solo úsalo en tus ramas personales — nunca en `develop` ni `main`.

**¿Cuándo hacer esto?**
- Cada vez que se mergee un PR a `develop`
- Al inicio del día antes de empezar a trabajar
- Antes de abrir un PR

---

### ¿Qué es un Pull Request (PR)?

Un PR es una solicitud para integrar tu rama a `develop`. Es el momento donde el equipo revisa el código antes de que entre al proyecto.

**Un PR debe tener:**
- Título con formato Conventional Commits: `feat(auth): google oauth login`
- Descripción breve de qué hace y cómo probarlo localmente
- Al menos **1 aprobación** del equipo antes de mergear

**Cómo mergearlo:**
Usar siempre **Squash and merge** — agrupa todos tus commits en uno solo y mantiene el historial limpio.

**Nunca mergees tu propio PR** — siempre que otro integrante lo revise primero.

### Reglas de ramas en GitHub

Ir a **Settings → Branches → Add branch ruleset** y configurar para `main` y `develop`:

- ✅ Require a pull request before merging
- ✅ Required approvals: 1
- ✅ Require branches to be up to date before merging
- ✅ Block force pushes

Esto evita pushes directos accidentales a las ramas protegidas.

### Resumen visual
develop
│
├── feature/auth-login ──────────────── PR → develop
├── feature/user-profile ────────────── PR → develop
└── feature/occupation-crud ─────────── PR → develop
│
PR → main (release)
 