using ChatServer.DAL;
using ChatServer.Data;
using ChatServer.Services;
using ChatServer.Utils;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

builder.WebHost.ConfigureKestrel(options =>
{
   //options.ListenAnyIP(5002); // 端口
   //options.ListenAnyIP(7001, configure => configure.UseHttps()); // https 端口
});
// 添加控制器并配置JSON序列化（camelCase）
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
    });

// 添加Swagger（接口文档）
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// 配置SQLite数据库
builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseSqlite(builder.Configuration.GetConnectionString("SqliteConnection"));
});
// 读取appsettings.json中的JwtSettings配置
var jwtSettings = builder.Configuration.GetSection("JwtSettings");

// 后续使用jwtSettings获取具体参数
string secretKey = jwtSettings["SecretKey"]!;    // 获取密钥
string issuer = jwtSettings["Issuer"]!;          // 获取签发者
string audience = jwtSettings["Audience"]!;      // 获取接收者
int expiresHours = int.Parse(jwtSettings["ExpiresHours"]!); // 获取有效期

// 确保JWT验证参数正确（与客户端一致）
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            // 生产环境建议设为true，测试环境可临时设为false
            ValidateIssuer = true,
            ValidateAudience = true,
            //ValidateIssuer = false, // 临时关闭签发者验证
            //ValidateAudience = false, // 临时关闭接收者验证

            ValidateLifetime = true, // 必须开启，验证令牌有效期
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtSettings["Issuer"], // 与客户端一致
            ValidAudience = jwtSettings["Audience"], // 与客户端一致
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings["SecretKey"]!)),
            // 新增：允许一定的时间偏差（解决客户端服务端时间不一致问题）
            ClockSkew = TimeSpan.FromMinutes(5)
        };
        options.UseSecurityTokenValidators = true;
        // 新增：打印401错误详情（调试用）
        options.Events = new JwtBearerEvents
        {
            OnAuthenticationFailed = context =>
            {
                Console.WriteLine($"JWT验证失败：{context.Exception.Message}");
                return Task.CompletedTask;
            },
            OnChallenge = context =>
            {
                Console.WriteLine($"JWT挑战失败：{context.ErrorDescription}");
                return Task.CompletedTask;
            }
        };
    });

// 注册服务
builder.Services.AddScoped<JwtHelper>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<ChatService>();
// 注册数据访问层
builder.Services.AddScoped<CollectionDAL>();
// 其他DAL注册（如 UserDAL、ChatRecordDAL 等）
// builder.Services.AddScoped<UserDAL>();
// builder.Services.AddScoped<ChatRecordDAL>();
// 注册好友DAL
builder.Services.AddScoped<FriendDAL>();
builder.Services.AddScoped<UserDAL>();

// 注册朋友圈DAL
builder.Services.AddScoped<MomentDAL>();

// 跨域配置
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader() // 必须允许所有头，包含Authorization
              .WithExposedHeaders("Authorization"); // 暴露Authorization头
    });
});

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    dbContext.Database.EnsureCreated();
}

// 开发环境启用Swagger
// if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
// 跨域
app.UseCors("AllowAll");

// 认证授权
app.UseAuthentication();
app.UseAuthorization();

// 路由
app.MapControllers();

app.Run();