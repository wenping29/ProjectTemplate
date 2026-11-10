#!/usr/bin/env bash
# 数据导入脚本
# 用法: bash import.sh [csv_file]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"
PSQL=$(require_pg_client psql PSQL)

CSV_PATH="${1:-$SCRIPT_DIR/sample_users.csv}"
HOST=${DB_HOST:-localhost}; PORT=${DB_PORT:-5432}
USER=${DB_USER:-app_rw}; DB=${DB_NAME:-app_db}
echo "==> 导入 $CSV_PATH 到 $DB"
"$PSQL" -h "$HOST" -p "$PORT" -U "$USER" -d "$DB" -c "\copy users(username,email,display_name,password_hash,role_id,status) FROM '$CSV_PATH' WITH (FORMAT csv, HEADER true);"
echo "==> 完成"
