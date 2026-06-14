# Registro de Empresas

App Flutter para gestionar empresas y empleados. El backend está en [`server/`](server/README.md).

## Requisitos

- Flutter SDK con Dart `^3.11.3`.
- Bun 1.x.
- PostgreSQL, local o con Docker.

## Ejecutar

API:

```bash
cd server
bun install
cp .env.example .env
docker compose up -d
bun run prisma:deploy
bun run prisma:generate
bun run dev
```

App:

```bash
flutter pub get
flutter run
```

La URL por defecto es `http://localhost:3000/api`.

Para Android Emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

Para celular físico, usa la IP de tu PC:

```bash
flutter run --dart-define=API_BASE_URL=http://<IP_DE_TU_PC>:3000/api
```
