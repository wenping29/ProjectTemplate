# 服务端 (Server) — ASP.NET Core Web API

技术栈：**.NET 10 / ASP.NET Core / EF Core / Npgsql (PostgreSQL) / JWT**。

覆盖需求：**角色管理、用户管理、菜单管理、功能管理、系统配置**，并内置登录/注册与鉴权。

## 目录结构
```
Server/
├── Server.sln
└── Server.Api/
    ├── Program.cs                # 入口：DbContext / JWT / 依赖注入 / 中间件
    ├── appsettings.json          # 连接串 + JWT 密钥
    ├── Common/                   # ApiResult（统一响应）、JwtOptions
    ├── Models/                   # 实体：Role/User/Menu/Permission/RoleMenu/RolePermission/SystemConfig/Product
    ├── Data/AppDbContext.cs      # EF 上下文（表名/列名 snake_case 对齐 DB 脚本）
    ├── DTOs/ApiDtos.cs           # 请求/响应模型
    ├── Services/                 # 业务逻辑（IAuthService 等）
    ├── Middleware/ExceptionMiddleware.cs
    └── Controllers/              # 接口实现
```

## 运行
```bash
cd Server
dotnet restore
dotnet run --project Server.Api     # https://localhost:5001 （Swagger 在 /swagger）
```
> 首次运行前请先执行 `../DB/build/run.sh` 建库建表并写入种子数据（含 admin 账号）。

## API 一览（统一前缀 /api，统一返回 { code, message, data }）
| 模块 | 方法 | 路径 | 说明 |
| --- | --- | --- | --- |
| 健康检查 | GET | `/api/health` | 存活探针 |
| 认证 | POST | `/api/auth/login` | 登录，返回 `accessToken` |
| 认证 | POST | `/api/auth/register` | 注册（默认角色 user） |
| 角色 | GET/POST | `/api/roles` | 角色列表 / 新建 |
| 角色 | GET/PUT/DELETE | `/api/roles/{id}` | 查询/更新/删除 |
| 角色 | POST | `/api/roles/{id}/grant` | 角色授权（菜单+功能） |
| 用户 | GET/POST | `/api/users` | 用户列表(支持 q 搜索) / 新建 |
| 用户 | GET/PUT/DELETE | `/api/users/{id}` | 查询/更新/删除(软删) |
| 用户 | PUT | `/api/users/me/profile` | 修改个人信息（需登录） |
| 用户 | POST | `/api/users/me/avatar` | 上传头像（multipart，返回 URL）— **待实现** |
| 用户 | DELETE | `/api/users/me` | 账号注销（停用当前账号）— **待实现** |
| 菜单 | GET/POST | `/api/menus` | 菜单列表 / 新建 |
| 菜单 | GET | `/api/menus/tree` | 树形菜单（后台树 / App 底部菜单） |
| 菜单 | GET/PUT/DELETE | `/api/menus/{id}` | 查询/更新/删除 |
| 功能 | GET/POST | `/api/permissions` | 功能列表 / 新建 |
| 功能 | GET/PUT/DELETE | `/api/permissions/{id}` | 查询/更新/删除 |
| 系统配置 | GET | `/api/system-config` | 配置列表（可按 group 过滤） |
| 系统配置 | GET | `/api/system-config/public` | 公开配置（免登录） |
| 系统配置 | POST/DELETE | `/api/system-config[/id]` | 新增或更新 / 删除 |

## 约定
- 鉴权：Bearer JWT（登录后 `Authorization: Bearer <token>`）。
- 密码：BCrypt 哈希，与 `DB/build/03_seed.sql` 中 `pgcrypto` 生成的哈希兼容。
- 时间：`timestamptz` 以 UTC 存储，由数据库触发器维护 `updated_at`。
- 软删除：用户/商品通过 `deleted_at` 标记。

## 已知限制 / TODO

- **以下两个端点尚未实现**（App 的「上传头像」「账号注销」功能依赖它们，App 端已写好调用代码）：
  - `POST /api/users/me/avatar`：接收 `multipart/form-data` 的 `file`，保存后返回头像 URL。
  - `DELETE /api/users/me`：停用/删除当前登录账号（建议软删并清理 token）。
  - 实现参考：`UsersController.UpdateProfileAsync` + `IUserService`，`CurrentUserId` 已在基类提供。
- 文件上传未引入 `IFormFile` / 本地存储 / 对象存储，需按部署环境补充（如 MinIO / S3）。
