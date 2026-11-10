# myapp

A new Flutter project.

nohup ./ChatServer output to nohup.out


## Getting Started
lib/
├── main.dart          # 程序入口
├── pages/             # 所有页面文件夹
│   ├── login_page.dart      # 登录页面
│   ├── register_page.dart   # 注册页面
│   ├── forgot_pwd_page.dart # 找回密码页面
│   ├── message_page.dart    # 消息页面
│   ├── friend_page.dart     # 好友页面
│   ├── moments_page.dart    # 朋友圈页面
│   ├── mine_page.dart       # 我的页面
│   └── main_nav_page.dart   # 底部导航主页面
└── widgets/           # 通用组件（可选，这里简化）
    └── common_widgets.dart  # 通用样式/组件
    
# Flutter 登录注册Demo - 核心功能说明
## 整体功能架构
该Demo包含完整的登录、注册、个人中心及各类功能页面，覆盖移动端APP基础交互场景。

## 页面功能明细
| 页面名称| 核心交互功能| 特殊说明|
|---|---|---|
| 登录页面| 账号密码验证、密码显隐切换、加载状态、跳转到注册页| 支持邮箱格式校验|
| 注册页面| 表单验证（用户名/邮箱/密码）、两次密码一致性校验、返回登录页| 邮箱格式严格校验|
| 个人中心页面| 退出登录（带确认弹窗）、所有功能入口跳转| 统一的菜单样式|
| 个人信息页面| 编辑/保存信息、更换头像、修改姓名/性别/手机号/邮箱| 支持编辑/非编辑状态切换|
| 支付页面| 支付方式管理、余额查看、支付记录、支付密码设置、支付通知开关| 开关操作有即时反馈|
| 账户安全页面| 修改密码、绑定手机/邮箱、指纹登录开关、设备管理、账号注销（带确认弹窗）| 账号注销有二次确认|
| 我的收藏页面| 查看收藏列表、取消收藏、清空收藏、空状态展示| 模拟真实收藏数据|
| 朋友圈页面| 发布朋友圈、查看动态、点赞评论、图片展示| 支持多图展示|
| 表情管理页面| 下载/删除表情包、查看表情分类、添加自定义表情| 区分已安装/未安装表情|
| 设置页面| 开关设置、清除缓存、版本信息、隐私政策等| 分组式布局，符合设计规范|

## 通用交互规范
1. **返回逻辑**：所有子页面都有返回按钮，点击可回到上一级页面
2. **操作反馈**：所有操作（开关、删除、保存等）都有SnackBar提示
3. **弹窗确认**：危险操作（注销账号、清空收藏、清除缓存）需二次确认
4. **UI风格**：统一的颜色（蓝色主色调）、间距、图标样式，符合移动端设计规范

## 技术实现要点
1. 表单验证：使用GlobalKey<FormState>实现表单合法性校验
2. 状态管理：使用setState管理页面局部状态（开关、编辑状态等）
3. 页面跳转：使用Navigator.push/pop实现页面导航
4. 组件封装：提取通用组件（设置项、菜单项），提高代码复用性
5. 数据模拟：所有页面都模拟真实业务数据，贴近实际开发场景



name: build ios
run-name: ${{ github.actor }} is build ios
on:
  push:
    branches: [ main ]

jobs:
  build:
   runs-on: ubuntu-latest
   steps:
      - name: 检出代码
        uses: actions/checkout@v4
      - name: 安装 Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.41.4'
      - name: 安装 Flutter 依赖
        run: |
          cd myapp
          flutter pub get
      - name: 运行代码检查
        run: |
          cd myapp
          flutter analyze
      - name: 构建 APK
        run: |
          cd myapp
          flutter build apk --release
      - name: Upload APK Artifact
        uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: build/app/outputs/apk/release/app-release.apk




    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
    location /test/ {
      proxy_pass http://127.0.0.1:5003/;
      root   /usr/share/nginx/html;
      index  index.html index.htm;
      proxy_set_header Host $http_host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header REMOTE-HOST $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    505d9689756a10fb34f1361c1cec5212
