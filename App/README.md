# 移动端 App — Flutter

基于 Flutter 的跨平台移动端模板，覆盖需求：**底部菜单配置、我的页面、个人信息修改、登录、注册、首页、上传头像、账号切换、账号注销、账户退出**。

## 技术栈
- Flutter 3.x (Dart)
- Dio（HTTP + JWT 拦截器）
- Provider（鉴权/账号状态）
- shared_preferences（token + 多账号）
- image_picker（上传头像）
- cached_network_image（头像展示）

## 目录结构
```
lib/
├── main.dart                  # 入口：组装依赖 + 初始化账号
├── app/
│   ├── app.dart              # MaterialApp + 路由（按登录态决定首屏）
│   └── routes.dart           # 路由常量
├── config/app_config.dart    # API 地址等配置
├── models/                   # user.dart / menu_item.dart
├── services/                 # storage / api / auth
├── providers/auth_provider.dart  # 登录/注册/切换/注销/退出
├── widgets/main_shell.dart   # 含可配置底部菜单的主框架
└── pages/                    # login / register / home / profile / edit_profile
```

## 运行
> 本机需已安装 Flutter SDK（当前环境未安装，故为手写骨架，未执行 `flutter create`）。
```bash
cd App
flutter pub get
flutter create --project-name app . --org com.example   # 生成 android/ios 原生工程
flutter run
```

## 功能对应
| 需求 | 实现位置 |
| --- | --- |
| 登录 / 注册 | `pages/login_page.dart` / `register_page.dart` + `AuthProvider.login/register` |
| 首页 | `pages/home_page.dart` |
| 底部菜单配置 | `widgets/main_shell.dart`（默认两项；可由 `GET /api/menus/tree` 下发覆盖） |
| 我的页面 | `pages/profile_page.dart` |
| 个人信息修改 | `pages/edit_profile_page.dart` + `AuthProvider.updateProfile` |
| 上传头像 | `AuthProvider.uploadAvatar` → 调 `POST /api/users/me/avatar`（**服务端待实现**） |
| 账号切换 | `ProfilePage` 底部弹窗 + `AuthProvider.switchTo`（多账号存于 shared_preferences） |
| 账号注销 | `AuthProvider.deactivate` → 调 `DELETE /api/users/me`（**服务端待实现**） |
| 账户退出 | `AuthProvider.logout` |

> ⚠️ **待实现依赖**：移动端「上传头像」「账号注销」的调用代码已就绪（`AuthService.uploadAvatar` / `deactivateAccount`），
> 但服务端 `POST /api/users/me/avatar` 与 `DELETE /api/users/me` 尚未实现，需在 `Server/Server.Api/Controllers/UsersController.cs` 中补充。
> 在此之前，这两项调用会返回 404。
