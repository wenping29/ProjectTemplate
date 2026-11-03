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

## 常见问题 (Troubleshooting)

- **`flutter run` 报 “Target of URI hasn't been found” / “The imported library … doesn't exist”**：
  模板早期版本的子目录文件用了错误的相对导入路径（如 `lib/app/app.dart` 写成 `import 'providers/...'`）。
  现已全部修正为 `../xxx`。请确保拿到最新文件，并在 `App/` 下重新执行 `flutter pub get`。
- **`flutter run` 报找不到目标 / 无 `android/`、`ios/` 目录**：
  模板只含 `lib/` 源码，**不含平台壳工程**。必须先用
  `flutter create --project-name app . --org com.example` 生成原生工程，再 `flutter run`
  （可用 `-d chrome` 跑 Web，或连接模拟器/真机）。
- **`image_picker` 运行时崩溃（选图/拍照）**：
  iOS 需在 `ios/Runner/Info.plist` 补全相册/相机权限描述；
  Android 需在 `android/app/src/main/AndroidManifest.xml` 加相机与存储权限
  （`flutter create` 生成的默认配置通常已含部分权限，按需补全）。
- **本机未安装 Flutter SDK**：`flutter run` 会直接报 `command not found`。
  请先安装 Flutter 并配置 `flutter doctor` 通过后再运行。

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
