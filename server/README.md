# Server

API Bun para autenticación, empresas y empleados.

## Requisitos

- Bun 1.x.
- PostgreSQL, local o con Docker.

## Ejecutar

```bash
cd server
bun install
cp .env.example .env
docker compose up -d
bun run prisma:deploy
bun run prisma:generate
bun run dev
```

La API queda en `http://localhost:3000`.

```bash
curl http://localhost:3000/health
```

Para apagar PostgreSQL local:

```bash
docker compose down
```

## Endpoints

Públicos:

- `GET /health`
- `POST /api/auth/register`
- `POST /api/auth/login`

Protegidos con `Authorization: Bearer <token>`:

- `GET /api/companies`
- `GET /api/companies?search=value`
- `POST /api/companies`
- `GET /api/companies/:id`
- `PUT /api/companies/:id`
- `DELETE /api/companies/:id`
- `GET /api/companies/:id/employees`
- `POST /api/companies/:id/employees`
- `PUT /api/companies/:id/employees/:employeeId`
- `DELETE /api/companies/:id/employees/:employeeId`
