# 后台管理 (Admin) — React + TypeScript + Vite + Ant Design

面向「系统管理」的前后台模板，覆盖：**用户管理、角色管理、菜单管理、功能管理、系统配置**，与 `Server/` 接口一一对应。

## 技术栈
- React 18 + TypeScript + Vite
- Ant Design 5（UI 组件）
- React Router 6（路由 + 登录守卫）
- Axios（统一请求封装 + JWT 注入 + 401 跳转）
- Zustand（轻量鉴权状态）

## 运行
```bash
cd Admin
npm install
npm run dev        # http://localhost:5173
```
> 开发期 `vite.config.ts` 已将 `/api` 代理到 `https://localhost:5001`（即 Server）。正式部署时改为网关地址。

## 目录
```
src/
├── api/            # request.ts(axios 封装) + system.ts(各模块 API)
├── store/auth.ts   # 登录态（token / 当前用户）
├── router/         # 路由 + RequireAuth 守卫
├── layouts/        # BasicLayout（侧边菜单 + 顶栏退出）
└── pages/          # Login / Dashboard / roles / users / menus / functions / config
```

## 与 Server 的对应
| 页面 | 接口 |
| --- | --- |
| 用户管理 | `GET/POST /api/users`、`PUT/DELETE /api/users/{id}`、`PUT /api/users/me/profile` |
| 角色管理 | `GET/POST/PUT/DELETE /api/roles`、`POST /api/roles/{id}/grant` |
| 菜单管理 | `GET/POST/PUT/DELETE /api/menus`、`GET /api/menus/tree` |
| 功能管理 | `GET/POST/PUT/DELETE /api/permissions` |
| 系统配置 | `GET/POST/DELETE /api/system-config` |

> 菜单可改为由 `GET /api/menus/tree` 动态渲染（当前为静态配置，便于无后端时预览）。
