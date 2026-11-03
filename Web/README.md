# 官网 (Web) — Vue 3 + TypeScript + Vite + Element Plus

面向 C 端访客的官网模板，覆盖需求：**账号注册、登录、主页、个人信息修改、头像修改、关于、招聘**。

## 技术栈
- Vue 3 (`<script setup>`) + TypeScript + Vite
- Element Plus（UI 组件）+ @element-plus/icons-vue
- Vue Router 4（路由 + 登录守卫 `meta.auth`）
- Pinia（用户状态）
- Axios（统一请求封装 + JWT）

## 运行
```bash
cd Web
npm install
npm run dev        # http://localhost:5174
```
> 开发期 `/api` 已代理到 `https://localhost:5001`（Server）。

## 目录
```
src/
├── api/         # request.ts(axios 封装) + auth.ts(登录/注册/改资料)
├── stores/user.ts # Pinia 用户状态
├── router/      # 路由 + 鉴权守卫
├── views/       # Home / Login / Register / Profile / About / Recruitment
└── App.vue      # 顶部导航 + 路由出口
```

## 页面与接口对应
| 页面 | 说明 | 接口 |
| --- | --- | --- |
| 注册 | 账号注册 | `POST /api/auth/register` |
| 登录 | 账号登录 | `POST /api/auth/login` |
| 主页 | 官网首页 | — |
| 个人信息 / 头像 | 修改资料、修改头像 | `PUT /api/users/me/profile` |
| 关于 | 公司介绍 | — |
| 招聘 | 职位列表 | — |

> 头像修改：当前为本地预览 + 回写 `avatarUrl` 的演示实现；生产环境请先将文件上传至文件服务 / OSS，再把返回的地址写入用户资料。
