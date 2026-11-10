ChatServer/
├── Controllers/          # API接口控制器
│   ├── AuthController.cs # 登录/注册/找回密码
│   ├── ChatController.cs # 聊天会话/消息管理
│   └── UserController.cs # 用户信息管理
├── Models/               # 数据模型
│   ├── User.cs           # 用户模型
│   ├── ChatSession.cs    # 聊天会话模型
│   └── ChatMessage.cs    # 聊天消息模型
├── Data/                 # 数据库上下文
│   └── AppDbContext.cs   # EF Core上下文
├── DTOs/                 # 数据传输对象
│   ├── LoginRequest.cs
│   ├── RegisterRequest.cs
│   ├── SendMessageRequest.cs
│   └── ResponseDto.cs
├── Services/             # 业务逻辑层
│   ├── AuthService.cs
│   └── ChatService.cs
├── Utils/                # 工具类
│   ├── JwtHelper.cs      # JWT生成/验证
│   └── MD5Helper.cs      # 密码加密
├── appsettings.json      # 配置文件（数据库/JWT）
└── ChatServer.csproj     # 项目文件



三、项目部署与使用说明
1. 环境准备
安装 .NET 8.0 SDK
安装 MySQL 8.0+
执行上述 SQL 脚本创建数据库和表
2. 配置项目
修改 appsettings.json 中的 MySQL 连接字符串（替换 root 和 你的MySQL密码）
替换 JWT 的 SecretKey 为随机长字符串（生产环境必改）
3. 运行项目
bash
运行
# 恢复依赖
dotnet restore

# 运行项目
dotnet run

# 发布项目（生产环境）
dotnet publish -c Release -o publish
4. 接口访问
接口文档：http://localhost:5000/swagger
登录接口：POST http://localhost:5000/api/Auth/Login
会话列表：GET http://localhost:5000/api/Chat/Sessions（需 JWT 令牌）
发送消息：POST http://localhost:5000/api/Chat/SendMessage（需 JWT 令牌）
四、核心亮点
安全可靠：密码 MD5 加密、JWT 认证、接口权限控制
性能优化：数据库索引、懒加载、消息批量处理
易扩展：分层架构（控制器 - 服务 - 数据），可快速添加群聊、文件传输等功能
适配前端：接口返回格式统一，完美对接之前的 Flutter App
轻量高效：基于ASP.NET Core，跨平台部署（Windows/Linux/Mac）