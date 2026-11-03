#!/usr/bin/env bash
# 数据库恢复 (从备份文件)
# 用法: bash restore.sh <backup_file.sql.gz> [env]
set -euo pipefail
FILE=${1:?请提供备份文件路径}
ENV=${2:-dev}
HOST=${DB_HOST:-localhost}; PORT=${DB_PORT:-5432}
USER=${DB_USER:-app_rw}; DB=${DB_NAME:-app_db_$ENV}
echo "==> 从 $FILE 恢复到 $DB"
gunzip -c "$FILE" | psql -h "$HOST" -p "$PORT" -U "$USER" -d "$DB"
echo "==> 恢复完成"
