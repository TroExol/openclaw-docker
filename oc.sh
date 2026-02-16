#!/usr/bin/env bash
# ==============================================================================
# OpenClaw Docker Manager (coollabsio/openclaw)
#
#   ./oc.sh start     — запустить
#   ./oc.sh stop      — остановить
#   ./oc.sh restart   — перезапустить
#   ./oc.sh logs      — логи (follow)
#   ./oc.sh update    — подтянуть новый образ + перезапустить
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
    echo "[oc] Подтягиваю свежие образы..."
    docker compose pull
    echo "[oc] Перезапускаю..."
    docker compose up -d
    echo "[oc] Обновление завершено."
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
    echo "  update    Обновить образ + перезапустить"
    echo "  backup    Бэкап вручную"
    echo "  health    Проверка здоровья"
    ;;
esac
