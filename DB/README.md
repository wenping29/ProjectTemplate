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
├── dbeaver/           # GUI 一键导入脚本（DBeaver 单文件）
│   ├── app_db_init.sql    # 自包含、幂等，详见下方「DBeaver / GUI 一键导入」
│   └── grant_app_access.sql # 修复 app_rw/app_ro 对既有表的权限（42501 排错用）
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

## DBeaver / GUI 一键导入

不想用命令行？`dbeaver/app_db_init.sql` 是一个**自包含、幂等**的单文件脚本，可在 DBeaver（或其他 SQL 客户端）中直接打开执行。

### 操作步骤
1. （若 `app_db` 尚不存在）在 `postgres` 维护连接上，取消注释并执行文件末尾「附录A：建库」，先建库；
2. **用「数据库所有者 / 超级用户（postgres）」身份**连接并切换到 `app_db`；
3. 打开 `dbeaver/app_db_init.sql` → 全选 → 工具栏「执行 SQL 脚本」（或 Ctrl+A 后 Ctrl+Enter）。

脚本会自动完成：创建并授权应用账号 `app_rw`(读写)/`app_ro`(只读) → 扩展 → 表结构 → 索引 → 触发器 → 种子数据 → 显式把全部表授权给应用账号。全程使用 `IF NOT EXISTS` / `ON CONFLICT` / `DROP TRIGGER IF EXISTS`，可重复执行。

### ⚠️ 常见报错：ERROR 42501 permission denied for schema public
这是 PostgreSQL 15+ 的安全收紧导致的——**只有库所有者/superuser 才能在 `public` 模式里建对象**。若用 `app_rw`、普通业务账号或只读账号连接去执行本脚本，第一条 `CREATE TABLE` 就会报这个错。
- 解决：**改用 postgres（所有者）身份连接后重新全选执行**即可。
- 脚本本身已在开头预置了 `GRANT USAGE, CREATE ON SCHEMA public TO app_rw` 等授权，并以所有者身份建表，因此只要连对账号就不会再出现此错。
- 若你确实只能用非所有者账号，请让 DBA 先执行：`ALTER SCHEMA public OWNER TO <你的账号>;` 或 `GRANT CREATE, USAGE ON SCHEMA public TO <你的账号>;`，再跑本脚本。

### ⚠️ 常见报错：ERROR 42501 permission denied for table xxx（用 app_rw 查询时）
**原因**：`menus` 等表是在授权生效**之前**（或由其他所有者）创建的。`ALTER DEFAULT PRIVILEGES` 只影响"此后新建"的表，对已存在的表不生效，所以 `app_rw` 没拿到这些既有表的权限。
**解决**：用**表的所有者 / superuser（postgres）**连接 `app_db`，执行 `dbeaver/grant_app_access.sql`——它会把 `public` 下所有既有表/序列授权给 `app_rw`/`app_ro`，并设置默认权限防止复发。执行后用文件末尾的验证 SQL（取消注释）可查看各表授权结果。

## 应用账号说明

| 账号 | 权限 | 用途 |
| --- | --- | --- |
| `app_rw` | read-write（读写）app_rw_pass | 应用主连接账号：CONNECT + USAGE/CREATE on schema public + 所有表的 SELECT/INSERT/UPDATE/DELETE。用于 Server `appsettings.json`、config/database.yml(dev/prod)、import/backup/sync 脚本 |
| `app_ro` | read-only（只读）app_ro_pass | 仅 SELECT。用于报表/只读查询（当前在 database.yml 的 test 环境作示例） |

> 这两个账号由本模块脚本创建，与 `roles` 表内的 `admin`/`user`（应用业务角色）不是同一概念。

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
