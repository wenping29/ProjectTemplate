#!/usr/bin/env bash
# 数据库备份 (pg_dump)
# 用法: bash backup.sh [env]
set -euo pipefail
ENV=${1:-dev}
HOST=${DB_HOST:-localhost}; PORT=${DB_PORT:-5432}
USER=${DB_USER:-app_rw}; DB=${DB_NAME:-app_db_$ENV}
DIR=${BACKUP_DIR:-./backups}
mkdir -p "$DIR"
TS=$(date +%Y%m%d_%H%M%S)
OUT="$DIR/${DB}_${TS}.sql.gz"
echo "==> 备份 $DB -> $OUT"
pg_dump -h "$HOST" -p "$PORT" -U "$USER" -d "$DB" --no-owner --clean --if-exists | gzip > "$OUT"
echo "==> 备份完成: $OUT"
