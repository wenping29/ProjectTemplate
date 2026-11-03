# 项目模板 (Monorepo Template)

一套统一技术栈的多端项目模板，包含移动端、后台管理、官网、服务端和数据库脚本。

## 技术栈

| 模块 | 技术 | 目录 | 包管理 / 构建 |
| --- | --- | --- | --- |
| 移动端 App | Flutter (Dart) | `App/` | `flutter pub get` |
| 后台管理 Admin | React 18 + TypeScript + Vite + Ant Design | `Admin/` | `npm install` |
| 官网 Web | Vue 3 + TypeScript + Vite + Element Plus | `Web/` | `npm install` |
| 服务端 Server | ASP.NET Core (C#) Web API | `Server/` | `dotnet run` |
| 数据库 DB | PostgreSQL (DDL 脚本) | `DB/` | `psql -f` |

## 架构概览

```
┌──────────┐   ┌──────────┐   ┌──────────┐
│  Web     │   │  Admin   │   │   App    │
│ (Vue 3)  │   │ (React)  │   │(Flutter) │
└────┬─────┘   └────┬─────┘   └────┬─────┘
     │              │              │
     └──────────────┼──────────────┘
                    │  HTTPS / JSON (REST, JWT Bearer)
                    ▼
            ┌──────────────────┐
            │  Server          │   ASP.NET Core Web API
            │  (C# / .NET 10)  │
            └────────┬─────────┘
                     │  EF Core (Npgsql)
                     ▼
            ┌──────────────────┐
            │  DB (PostgreSQL) │
            └──────────────────┘
```

## 统一约定

- **API**：RESTful，统一前缀 `/api`；请求/响应体为 JSON。
- **命名**：服务端返回 `camelCase`；数据库列名使用 `snake_case`。
- **时间**：数据库统一以 `timestamptz`（UTC）存储；前端展示时做本地化。
- **鉴权**：JWT（Bearer Token）。登录接口 `/api/auth/login` 返回 `accessToken`。
- **错误格式**：
  ```json
  { "code": 0, "message": "ok", "data": {} }
  ```
  `code != 0` 表示业务/系统错误。
- **示例领域模型**：`roles`（角色）、`users`（用户）、`products`（商品），三个端共用，便于联调。

## 模块功能对照

| 模块 | 技术栈 | 覆盖功能 |
| --- | --- | --- |
| 服务端 Server | ASP.NET Core (C#) Web API | 登录/注册（JWT）、**角色管理、用户管理、菜单管理、功能(权限)管理、系统配置** |
| 后台管理 Admin | React 18 + TS + Vite + Ant Design | 登录、仪表盘、**用户/角色/菜单/功能/系统配置**管理页（与 Server 接口一一对应） |
| 官网 Web | Vue 3 + TS + Vite + Element Plus | **账号注册、登录、主页、个人信息修改、头像修改、关于、招聘** |
| 移动端 App | Flutter (Dart) | **底部菜单配置、我的页面、个人信息修改、登录、注册、首页、上传头像、账号切换、账号注销、账户退出** |
| 数据库 DB | PostgreSQL 脚本 + 运维脚本 | **数据库配置、数据库搭建、数据导入、数据库备份、数据库迁移、数据库同步** |

> 各子目录均含独立 `README.md` 与 `.gitignore`（或沿用根 `.gitignore`），说明各自的运行方式与接口。

## 数据库模块说明

`DB/` 不只是建表脚本，而是覆盖数据库全生命周期的运维工具箱：

```
DB/
├── config/     数据库配置（多环境变量）
├── build/      数据库搭建（建库/建表/索引/种子，含 run.sh 一键执行）
├── import/     数据导入（CSV / SQL）
├── backup/     数据库备份与恢复
├── migrate/    数据库迁移（增量变更 + 版本管理）
└── sync/       数据库同步（环境间结构对齐）
```

## 快速开始

### 1. 数据库 (PostgreSQL)
```bash
cd DB
psql -U postgres -f 00_init.sql          # 建库、扩展、角色
psql -U postgres -d app_db -f 01_schema.sql
psql -U postgres -d app_db -f 02_indexes.sql
psql -U postgres -d app_db -f 03_seed.sql
```

### 2. 服务端 (C#)
```bash
cd Server
dotnet restore
dotnet run --project Server.Api   # 默认 https://localhost:5001
```

### 3. 后台管理 (React)
```bash
cd Admin
npm install
npm run dev                       # 默认 http://localhost:5173
```

### 4. 官网 (Vue)
```bash
cd Web
npm install
npm run dev                       # 默认 http://localhost:5174
```

### 5. 移动端 (Flutter)
> 本机需已安装 Flutter SDK。若 `App/` 缺少原生工程目录，先执行：
```bash
cd App
flutter create --project-name app . --org com.example
flutter pub get
flutter run
```

## 目录说明
- `Admin/`：React 后台管理（Ant Design + React Router + Axios + Zustand）。
- `Web/`：Vue 官网（Element Plus + Vue Router + Pinia + Axios）。
- `Server/`：ASP.NET Core Web API（EF Core + Npgsql + JWT）。
- `App/`：Flutter 移动端（登录 + 首页示例）。
- `DB/`：PostgreSQL 建库/建表/索引/种子脚本。

> 各子目录均含独立 `README.md` 与 `.gitignore`（或沿用根 `.gitignore`）。
