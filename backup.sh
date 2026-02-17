#!/usr/bin/env bash
# ==============================================================================
# Бэкап данных OpenClaw (Docker volume → tar.gz)
# Хранит последние 7 бэкапов, старые удаляет автоматически.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backups"
KEEP_DAYS=7

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/openclaw-backup-${TIMESTAMP}.tar.gz"

echo "[backup] Создаю бэкап volume openclaw-data..."
MSYS_NO_PATHCONV=1 docker run --rm \
  -v openclaw_openclaw-data:/data:ro \
  -v "$BACKUP_DIR":/backup \
  alpine tar -czf "/backup/openclaw-backup-${TIMESTAMP}.tar.gz" -C / data/

BACKUP_SIZE=$(du -sh "$BACKUP_FILE" | cut -f1)
echo "[backup] Готово: $BACKUP_FILE ($BACKUP_SIZE)"

# Удаляем бэкапы старше $KEEP_DAYS дней
find "$BACKUP_DIR" -name "openclaw-backup-*.tar.gz" -mtime +$KEEP_DAYS -type f | while read -r old; do
  rm -f "$old"
  echo "[backup] Удалён старый бэкап: $(basename "$old")"
done

echo "[backup] Завершено. Хранится бэкапов: $(ls -1 "$BACKUP_DIR"/openclaw-backup-*.tar.gz 2>/dev/null | wc -l)"
