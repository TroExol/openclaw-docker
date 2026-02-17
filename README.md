# OpenClaw Docker

**Docker-сетап для [OpenClaw](https://github.com/openclaw/openclaw) на базе [coollabsio/openclaw](https://github.com/coollabsio/openclaw).**

Кастомный образ с дополнительными инструментами, Qdrant для векторного поиска, управление одной командой, ежедневные бэкапы.

## Quick Start

```bash
cp example.env .env
# Заполнить .env — как минимум AUTH_PASSWORD и один провайдер (ANTHROPIC_API_KEY)

./rebuild-custom-image.sh   # собрать кастомный образ
./oc.sh start
```

Открыть `http://localhost:8080`, логин: `admin` / твой `AUTH_PASSWORD`.

## Требования

- Docker Desktop (или Docker Engine) + Docker Compose v2
- Bash (Git Bash на Windows подойдёт)

## Структура

```
openclaw/
├── Dockerfile              # кастомный образ (доп. инструменты)
├── rebuild-custom-image.sh # пересборка кастомного образа
├── example.env             # шаблон переменных окружения
├── docker-compose.yml      # compose (openclaw + browser + qdrant)
├── oc.sh                   # управление одной командой
├── backup.sh               # бэкап Docker volume
├── setup-backup-task.ps1   # планировщик бэкапа (Windows)
└── backups/                # архивы бэкапов
```

Данные хранятся в Docker volumes: `openclaw-data`, `browser-data`, `qdrant-data`.

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

## Кастомный образ

Проект использует собственный Docker-образ `openclaw:custom`, собранный поверх `coollabsio/openclaw:latest`. В него добавлены:

- **todoist-ts-cli** — CLI для Todoist
- **clawhub** — менеджер расширений OpenClaw
- **nano** — текстовый редактор

Пересборка после изменений в `Dockerfile`:

```bash
./rebuild-custom-image.sh
./oc.sh restart
```

## Qdrant

В комплекте [Qdrant](https://qdrant.tech/) — векторная БД для семантического поиска. Доступен на портах `6333` (REST) и `6334` (gRPC). Защита через `QDRANT_API_KEY` в `.env`.

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

Подтягивает свежие базовые образы (browser, qdrant) и перезапускает. Для обновления самого OpenClaw нужно также пересобрать кастомный образ:

```bash
docker pull coollabsio/openclaw:latest
./rebuild-custom-image.sh
./oc.sh update
```

## License

MIT
