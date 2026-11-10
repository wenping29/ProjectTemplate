#!/usr/bin/env bash
# DB/common.sh — 定位 PostgreSQL 客户端 (psql / pg_dump) 并提供友好报错。
# 被 DB 下各子目录脚本 source 使用。
# 解析优先级：
#   1) 环境变量 PSQL / PG_DUMP（绝对路径或命令名）
#   2) PATH 中的 psql / pg_dump
#   3) Windows 常见安装路径 C:\Program Files\PostgreSQL\<版本>\bin

_find_pg_client() {
  local bin_name="$1" env_var="$2"
  # 1) 环境变量（路径或命令名）
  if [[ -n "${!env_var:-}" ]]; then
    if [[ -f "${!env_var}" ]]; then
      printf '%s' "${!env_var}"; return 0
    fi
    if command -v "${!env_var}" >/dev/null 2>&1; then
      command -v "${!env_var}"; return 0
    fi
  fi
  # 2) PATH
  if command -v "$bin_name" >/dev/null 2>&1; then
    command -v "$bin_name"; return 0
  fi
  # 3) Windows 常见安装路径
  local pf="/c/Program Files/PostgreSQL"
  if [[ -d "$pf" ]]; then
    local ver
    ver=$(ls -1 "$pf" 2>/dev/null | sort -V | tail -1)
    if [[ -n "$ver" && -f "$pf/$ver/bin/$bin_name" ]]; then
      printf '%s' "$pf/$ver/bin/$bin_name"; return 0
    fi
  fi
  return 1
}

# 取出客户端路径；找不到则打印可操作指引并 exit 1。
require_pg_client() {
  local bin_name="$1" env_var="$2" path
  if ! path=$(_find_pg_client "$bin_name" "$env_var"); then
    echo "✗ 未找到 PostgreSQL 客户端: $bin_name" >&2
    echo "  原因：本机未安装 PostgreSQL，或客户端不在 PATH 中。" >&2
    echo "  解决方式（任选其一）：" >&2
    echo "    1) 安装 PostgreSQL（Windows 版默认装到 C:\\Program Files\\PostgreSQL\\<版本>\\bin，脚本会自动识别）" >&2
    echo "    2) 用 Docker 运行：docker run -d --name app_pg -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:16" >&2
    echo "    3) 手动指定：export PSQL=/绝对路径/psql  或  export PG_DUMP=/绝对路径/pg_dump" >&2
    echo "  注意：除客户端外，还需一个『正在运行的 PostgreSQL 服务』（默认端口 5432）。" >&2
    exit 1
  fi
  printf '%s' "$path"
}
