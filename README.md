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
### El estado de service_request
1. pending      → solicitud creada, esperando propuestas
2. accepted     → cliente aceptó una propuesta
3. in_progress  → colaborador marcó que comenzó el trabajo
4. completed    → trabajo culminado
5. cancelled    → cancelado por cualquiera de las partes
6. disputed     → en disputa / reclamo abierto

---
### Estado de ubicación del colaborador en Redis — solo disponibilidad:
1. available    → aparece en búsquedas
2. busy         → tiene un servicio activo, no aparece
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

## Autenticación

- Email + contraseña (provider: `local`)
- Google OAuth 2.0
- Facebook OAuth 2.0
- Apple Sign In

Todos los providers se almacenan en la tabla `user_providers`. Un usuario puede tener múltiples providers vinculados a la misma cuenta. El `password_hash` vive en `user_providers`, no en `users`.

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
| status | string |

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
| admin_sender_id | uuid FK → admin_users (nullable — null = sistema automático) |
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

## Cardinalidades

| Relación | Tipo |
|---|---|
| users — profile_colab | 1 a 0,1 |
| users — user_providers | 1 a M |
| users — service_request | 1 a M |
| users — post_like | 1 a M |
| users — post_comment | 1 a M |
| users — notification | 1 a M |
| users — suggestion | 1 a M |
| users — support | 1 a M |
| users — report (reporter) | 1 a M |
| users — report (reported) | 1 a M |
| users — conversation | 1 a M |
| users — message (sender) | 1 a M |
| users — user_follows | M a M (auto-relación) |
| profile_colab — occupation | M a M vía profile_colab_occupations |
| profile_colab — proposal | 1 a M |
| profile_colab — post | 1 a M |
| profile_colab — conversation | 1 a M |
| service_request — proposal | 1 a M |
| service_request — comment_request | 1 a 1 |
| conversation — message | 1 a M |
| post — post_like | 1 a M |
| post — post_comment | 1 a M |
| post — media | 1 a M (JSONB dentro de post) |
| admin_users — notification | 1 a M |
| admin_users — report | 1 a M |
| admin_users — suggestion | 1 a M |
| admin_users — support | 1 a M |

---

## Redis — ubicación de colaboradores

La ubicación del colaborador **nunca toca PostgreSQL**. Se almacena en Redis con TTL de 60 segundos. El app del colaborador la renueva automáticamente mientras está activo.

```json
{
  "lat": -12.046,
  "lng": -77.042,
  "occupation": "Electricidad",
  "status": "available"
}
```

Estados posibles: `available` | `busy`

- `available` → aparece en búsquedas del Flujo A y recibe chats
- `busy` → no aparece en búsquedas del Flujo A, pero sí recibe consultas de chat (el colaborador decide cuándo responder)

---

## Decisiones de arquitectura relevantes

- **No Clean Architecture por ahora** — se usan módulos nativos de NestJS. Se evalúa migrar cuando el proyecto lo justifique.
- **Un solo repositorio** — monorepo con carpetas separadas para backend y documentación. Flutter irá en repositorio aparte.
- **PostgreSQL en contenedor Docker** para desarrollo. Se evalúa migrar a managed database en producción.
- **Cloudinary** para almacenamiento y transformación de imágenes. No se usa Firebase Storage.
- **Sin Firebase** — autenticación, storage y base de datos son completamente independientes de Firebase.
- **Tracking visual de ruta** — se implementa en una versión posterior. La primera versión solo muestra estados: `aceptado → en camino → llegó`.
- **Panel de administración** — intranet separada con su propio sistema de login usando `admin_users`. Se construye después de la app móvil.

---

## Dependencias del backend (NestJS)

```bash
# Core
@nestjs/common
@nestjs/core
@nestjs/platform-express

# Base de datos
@nestjs/typeorm
typeorm
pg                          # Driver PostgreSQL
@nestjs/config              # Variables de entorno

# Autenticación
@nestjs/passport
@nestjs/jwt
passport
passport-local
passport-jwt
passport-google-oauth20
passport-facebook
bcrypt

# Validación
class-validator
class-transformer

# Redis
ioredis
@nestjs/cache-manager
cache-manager-ioredis

# WebSockets (chat en tiempo real)
@nestjs/websockets
@nestjs/platform-socket.io
socket.io

# Documentación
@nestjs/swagger
swagger-ui-express

# Utilidades
uuid
```

---

## Dependencias del frontend (Flutter)

```yaml
# Manejo de estado
flutter_bloc
equatable

# HTTP
dio

# Autenticación social
google_sign_in
flutter_facebook_auth
sign_in_with_apple

# Almacenamiento local
flutter_secure_storage      # JWT y datos sensibles
shared_preferences          # Preferencias generales

# Mapas y ubicación
google_maps_flutter
geolocator
geocoding

# Media
image_picker
cloudinary_flutter

# WebSockets
socket_io_client

# Utilidades
intl                        # Internacionalización y fechas
uuid
```

---

## Variables de entorno requeridas (.env)

```env
# Base de datos
DATABASE_HOST=
DATABASE_PORT=5432
DATABASE_NAME=colabs
DATABASE_USER=
DATABASE_PASSWORD=

# JWT
JWT_SECRET=
JWT_EXPIRES_IN=7d

# Redis
REDIS_HOST=
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

## Estado del proyecto

- [x] Definición del producto y casos de uso
- [x] Diseño UI en Figma
- [x] Modelo de datos v2.0
- [x] Decisiones de stack y arquitectura
- [ ] Estructura de carpetas del proyecto
- [ ] Setup inicial NestJS + Docker
- [ ] Módulo de autenticación
- [ ] Módulos del negocio
- [ ] App Flutter
- [ ] Panel de administración
