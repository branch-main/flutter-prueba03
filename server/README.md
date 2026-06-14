# Server

Bun API server for the company CRUD.

## Requirements

- Bun 1.x
- Docker, optional but recommended for local PostgreSQL
- A PostgreSQL database, local or cloud

## Setup

```bash
cd server
bun install
cp .env.example .env
docker compose up -d
bun run prisma:deploy
bun run prisma:generate
bun run dev
```

The server listens on `http://localhost:3000` by default.

You can change the host or port through environment variables:

```bash
PORT=3001 HOST=0.0.0.0 bun run start
```

## Environment variables

```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/flutter_prueba03?schema=public"
JWT_SECRET="change-this-secret-in-production"
JWT_EXPIRES_IN="7d"
HOST="0.0.0.0"
PORT="3000"
```

For production, set these values in the hosting provider dashboard, for example Render, Railway or EC2. Do not commit `.env`.

## Database

Local PostgreSQL is defined in `docker-compose.yml`.

For cloud PostgreSQL, replace `DATABASE_URL` with the connection string from Amazon RDS, Supabase or Neon, then run:

```bash
bun run prisma:deploy
bun run prisma:generate
```

## Public endpoints

- `GET /health`
- `POST /api/auth/register`
- `POST /api/auth/login`

## Protected endpoints

These endpoints require `Authorization: Bearer <token>`.

- `GET /api/companies`
- `GET /api/companies?search=value`
- `GET /api/companies/:id`
- `POST /api/companies`
- `PUT /api/companies/:id`
- `DELETE /api/companies/:id`
- `GET /api/companies/:id/employees`
- `POST /api/companies/:id/employees`

## Auth examples

Register:

```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@example.com","password":"secret123","name":"Admin"}'
```

Login:

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@example.com","password":"secret123"}'
```

Use the returned token:

```bash
curl http://localhost:3000/api/companies \
  -H 'Authorization: Bearer <token>'
```

## Company JSON shape

```json
{
  "id": 1,
  "name": "Company name",
  "taxId": "12345678901",
  "address": "Street 123",
  "businessLine": "Services",
  "isActive": true
}
```

## Employee JSON shape

```json
{
  "id": 1,
  "companyId": 1,
  "fullName": "Employee name",
  "documentNumber": "12345678",
  "position": "Manager",
  "email": "employee@example.com",
  "phone": "999999999",
  "isActive": true
}
```
