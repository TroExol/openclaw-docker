# OpenClaw Docker

**Docker-сетап для [OpenClaw](https://github.com/openclaw/openclaw) на базе [coollabsio/openclaw](https://github.com/coollabsio/openclaw).**

Готовый образ, управление одной командой, ежедневные бэкапы.

## Quick Start

```bash
cp example.env .env
# Заполнить .env — как минимум AUTH_PASSWORD и один провайдер (ANTHROPIC_API_KEY)

./oc.sh start
```

Открыть `http://localhost:8080`, логин: `admin` / твой `AUTH_PASSWORD`.

## Требования

- Docker Desktop (или Docker Engine) + Docker Compose v2
- Bash (Git Bash на Windows подойдёт)

## Структура

```
openclaw/
├── example.env           # шаблон переменных окружения
├── docker-compose.yml    # compose (openclaw + browser sidecar)
├── oc.sh                 # управление одной командой
├── backup.sh             # бэкап Docker volume
├── setup-backup-task.ps1 # планировщик бэкапа (Windows)
└── backups/              # архивы бэкапов
```

Данные хранятся в Docker volumes: `openclaw-data`, `browser-data`.

## Управление

| Команда | Описание |
|---------|----------|
| `./oc.sh start` | Запустить |
| `./oc.sh stop` | Остановить |
| `./oc.sh restart` | Перезапустить |
| `./oc.sh logs` | Логи (follow) |
| `./oc.sh update` | Обновить образ + перезапустить |
| `./oc.sh backup` | Бэкап вручную |
| `./oc.sh health` | Проверка здоровья |

## Конфигурация

Все токены передаются через `.env` → env-переменные контейнера → автоматически конвертируются в `openclaw.json` скриптом `configure.js`.

Полный список переменных: [coollabsio/openclaw README](https://github.com/coollabsio/openclaw#environment-variables).

## Браузер

В комплекте browser sidecar с VNC. Доступен по `http://localhost:8080/browser/`. Через него можно логиниться в сайты, OpenClaw переиспользует сессию через CDP.

## Бэкапы

```bash
./oc.sh backup
```

Автоматический бэкап каждый день в 03:00 (Windows):

```powershell
powershell -ExecutionPolicy Bypass -File setup-backup-task.ps1
```

Бэкапы хранятся 7 дней в `backups/`, старые удаляются автоматически.

## Обновление

```bash
./oc.sh update
```

Подтягивает свежий образ с Docker Hub и перезапускает. Образ обновляется автоматически в течение 6 часов после каждого релиза OpenClaw.

## License

MIT
