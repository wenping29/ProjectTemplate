#!/usr/bin/env bash
# 数据库同步 (Sync)
# 将一个环境的结构+数据同步到另一个环境（如 test -> prod 结构对齐）
# 用法: bash sync.sh <src_env> <dst_env>
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"
PG_DUMP=$(require_pg_client pg_dump PG_DUMP)
PSQL=$(require_pg_client psql PSQL)

SRC=${1:?源环境}; DST=${2:?目标环境}
HOST=${DB_HOST:-localhost}; PORT=${DB_PORT:-5432}; USER=${DB_USER:-app_rw}
SRC_DB=app_db_$SRC; DST_DB=app_db_$DST

echo "==> 将 $SRC_DB 结构同步到 $DST_DB（仅结构，--schema-only）"
"$PG_DUMP" -h "$HOST" -p "$PORT" -U "$USER" -d "$SRC_DB" --schema-only --no-owner \
  | "$PSQL" -h "$HOST" -p "$PORT" -U "$USER" -d "$DST_DB"

echo "==> 结构同步完成"
echo "    如需同步数据，请使用 backup.sh / restore.sh 或追加 --data-only"
