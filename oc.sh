#!/usr/bin/env bash
# ==============================================================================
# OpenClaw Docker Manager (coollabsio/openclaw)
#
#   ./oc.sh start     — запустить
#   ./oc.sh stop      — остановить
#   ./oc.sh restart   — перезапустить
#   ./oc.sh logs      — логи (follow)
#   ./oc.sh update    — обновить базовый образ + пересобрать custom + перезапустить
#   ./oc.sh rebuild   — пересобрать custom (без обновления базового)
#   ./oc.sh backup    — бэкап вручную
#   ./oc.sh health    — проверка здоровья
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

CMD="${1:-help}"
shift 2>/dev/null || true

case "$CMD" in
  start)
    echo "[oc] Запускаю..."
    docker compose up -d
    echo "[oc] OpenClaw запущен на http://localhost:$(grep -oP 'PORT=\K[0-9]+' .env 2>/dev/null || echo 8080)"
    ;;
  stop)
    echo "[oc] Останавливаю..."
    docker compose down
    ;;
  restart)
    echo "[oc] Перезапускаю..."
    docker compose restart
    ;;
  logs)
    docker compose logs -f openclaw
    ;;
  update)
    echo "[oc] Подтягиваю свежие базовые образы..."
    docker pull coollabsio/openclaw:latest
    docker pull coollabsio/openclaw-browser:latest
    echo "[oc] Пересобираю кастомный образ..."
    docker build --no-cache -t openclaw:custom .
    echo "[oc] Перезапускаю..."
    docker compose up -d
    echo "[oc] Обновление завершено."
    ;;
  rebuild)
    echo "[oc] Пересобираю кастомный образ (без обновления базового)..."
    docker build -t openclaw:custom .
    echo "[oc] Перезапускаю..."
    docker compose up -d
    echo "[oc] Готово."
    ;;
  backup)
    bash "$SCRIPT_DIR/backup.sh"
    ;;
  health)
    docker compose exec openclaw node dist/index.js health
    ;;
  *)
    echo "OpenClaw Docker Manager"
    echo ""
    echo "Использование: ./oc.sh <команда>"
    echo ""
    echo "Команды:"
    echo "  start     Запустить"
    echo "  stop      Остановить"
    echo "  restart   Перезапустить"
    echo "  logs      Логи (follow)"
    echo "  update    Обновить базовый образ + пересобрать custom + перезапустить"
    echo "  rebuild   Пересобрать custom (без обновления базового)"
    echo "  backup    Бэкап вручную"
    echo "  health    Проверка здоровья"
    ;;
esac
