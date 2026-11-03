# 数据库模块 (PostgreSQL 运维工具箱)

本目录不止是「建表脚本」，而是一个覆盖数据库全生命周期的运维工具箱，对应需求：
**数据库配置 / 数据库搭建 / 数据导入 / 数据库备份 / 数据库迁移 / 数据库同步**。

## 前置依赖

脚本依赖 **PostgreSQL 客户端**（`psql` / `pg_dump`）和 **一个正在运行的 PostgreSQL 服务**（默认端口 5432）。

- 客户端定位顺序：`$PSQL` / `$PG_DUMP` 环境变量 → 系统 PATH → Windows 默认安装路径 `C:\Program Files\PostgreSQL\<版本>\bin`。
- 若都找不到，脚本会打印可操作指引后退出，不会再出现 `psql: command not found` 这类裸错误。
- 没有本地 PostgreSQL 时，可用 Docker 临时起一个：
  ```bash
  docker run -d --name app_pg -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:16
  ```

## 目录结构

```
DB/
├── config/            # 数据库配置（多环境变量、连接串）
│   ├── database.yml
│   └── .env.example
├── build/             # 数据库搭建（建库/建表/索引/种子）
│   ├── 00_init.sql        # 建库、扩展(uuid-ossp/pgcrypto)、角色与授权
│   ├── 01_schema.sql      # 核心表：角色/用户/菜单/功能/角色菜单/角色功能/系统配置/商品
│   ├── 02_indexes.sql     # 索引
│   ├── 03_seed.sql        # 种子：角色 + 管理员(admin / Admin@123456)
│   ├── 04_seed_admin.sql  # 种子：菜单/功能/角色授权/系统配置
│   └── run.sh             # 一键搭建脚本
├── import/            # 数据导入（CSV / SQL）
│   ├── import.sql
│   ├── import.sh
│   ├── sample_users.csv
│   └── README.md
├── backup/            # 数据库备份与恢复
│   ├── backup.sh          # pg_dump 压缩备份
│   └── restore.sh         # 从备份恢复
├── migrate/           # 数据库迁移（增量变更）
│   ├── README.md
│   └── migrations/        # YYYYMMDD_NN_描述.sql
├── sync/              # 数据库同步（环境间结构对齐）
│   └── sync.sh
└── README.md
```

## 快速命令

```bash
# 配置
cp config/.env.example config/.env   # 填写真实连接信息

# 数据库搭建
cd build && bash run.sh dev

# 数据导入
cd import && bash import.sh sample_users.csv

# 备份 / 恢复
cd backup && bash backup.sh dev
bash restore.sh backups/app_db_dev_20260101_010000.sql.gz dev

# 迁移：在 migrate/migrations 新增脚本后手动或借助 Flyway/EF 执行

# 同步：将 test 结构同步到 prod
cd sync && bash sync.sh test prod
```

## 核心表说明
| 表 | 用途 | 对应功能 |
| --- | --- | --- |
| `roles` | 角色 | 角色管理 |
| `users` | 用户（含头像/手机/状态） | 用户管理 / App 注册登录 |
| `menus` | 菜单（目录/菜单/按钮） | 菜单管理 / App 底部菜单 |
| `permissions` | 功能/权限 | 功能管理 |
| `role_menus` / `role_permissions` | 角色授权 | RBAC |
| `system_config` | 系统配置（键值对/分组） | 系统配置 |
| `products` | 示例业务表 | 演示 |

> 连接串（供 Server `appsettings.json` 使用）：
> `Host=localhost;Port=5432;Database=app_db;Username=app_rw;Password=app_rw_pass`
