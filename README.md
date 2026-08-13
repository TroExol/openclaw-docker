**English** · [Русский](./README.ru.md)

# OpenClaw Docker

**A Docker setup for [OpenClaw](https://github.com/openclaw/openclaw), built on top of [coollabsio/openclaw](https://github.com/coollabsio/openclaw).**

Custom image with extra tooling, Qdrant for vector search, single-command management and scheduled backups.

## Quick start

```bash
cp example.env .env
# Fill in .env — at minimum AUTH_PASSWORD and one provider (ANTHROPIC_API_KEY)

./rebuild-custom-image.sh   # build the custom image
./oc.sh start
```

Open `http://localhost:8080` and log in with `admin` / your `AUTH_PASSWORD`.

## Requirements

- Docker Desktop (or Docker Engine) + Docker Compose v2
- Bash (Git Bash works on Windows)

## Layout

```
openclaw/
├── Dockerfile              # custom image (extra tooling)
├── rebuild-custom-image.sh # rebuild the custom image
├── example.env             # environment variable template
├── docker-compose.yml      # compose stack (openclaw + browser + qdrant)
├── oc.sh                   # single-command management
├── backup.sh               # Docker volume backup
├── setup-backup-task.ps1   # backup scheduler (Windows)
└── backups/                # backup archives
```

State lives in Docker volumes: `openclaw-data`, `browser-data`, `qdrant-data`.

## Management

| Command | Description |
|---------|-------------|
| `./oc.sh start` | Start |
| `./oc.sh stop` | Stop |
| `./oc.sh restart` | Restart |
| `./oc.sh logs` | Follow logs |
| `./oc.sh update` | Pull a newer image and restart |
| `./oc.sh backup` | Back up on demand |
| `./oc.sh health` | Health check |

## Configuration

Every token is passed through `.env` → container environment variables → and is converted into
`openclaw.json` automatically by `configure.js`.

For the full variable list see the [coollabsio/openclaw README](https://github.com/coollabsio/openclaw#environment-variables).

## Custom image

The stack runs a custom `openclaw:custom` image built on `coollabsio/openclaw:latest`, adding:

- **todoist-ts-cli** — Todoist CLI
- **clawhub** — OpenClaw extension manager
- **nano** — text editor

Rebuild after changing the `Dockerfile`:

```bash
./rebuild-custom-image.sh
./oc.sh restart
```

## Qdrant

[Qdrant](https://qdrant.tech/) ships with the stack as the vector database backing semantic search.
It is exposed on ports `6333` (REST) and `6334` (gRPC), protected by `QDRANT_API_KEY` in `.env`.

## Browser

A browser sidecar with VNC is included, reachable at `http://localhost:8080/browser/`. Use it to sign in
to sites manually — OpenClaw then reuses the authenticated session over CDP.

## Backups

```bash
./oc.sh backup
```

Daily automatic backups at 03:00 on Windows:

```powershell
powershell -ExecutionPolicy Bypass -File setup-backup-task.ps1
```

Backups are kept for 7 days in `backups/`; older archives are pruned automatically.

## Updating

```bash
./oc.sh update
```

This pulls fresh base images (browser, qdrant) and restarts the stack. Updating OpenClaw itself also
requires rebuilding the custom image:

```bash
docker pull coollabsio/openclaw:latest
./rebuild-custom-image.sh
./oc.sh update
```

## License

MIT
