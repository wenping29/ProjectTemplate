using ChatServer.Data;
using ChatServer.DTOs;
using ChatServer.Models;
using ChatServer.Utils;
using Microsoft.EntityFrameworkCore;

namespace ChatServer.Services;

public class AuthService
{
    private readonly AppDbContext _dbContext;
    private readonly JwtHelper _jwtHelper;

    public AuthService(AppDbContext dbContext, JwtHelper jwtHelper)
    {
        _dbContext = dbContext;
        _jwtHelper = jwtHelper;
    }

    // 用户登录
    public async Task<ResponseDto<string>> Login(LoginRequest request)
    {
        // 查找用户（支持邮箱/用户名登录）
        var user = await _dbContext.Users
            .FirstOrDefaultAsync(u => u.Email == request.Account || u.Username == request.Account);
        
        if (user == null)
        {
            return ResponseDto<string>.Fail("用户不存在", 404);
        }

        // 验证密码
        if (user.Password != MD5Helper.MD5Encrypt(request.Password))
        {
            return ResponseDto<string>.Fail("密码错误", 401);
        }

        // 更新最后登录时间
        user.LastLoginTime = DateTime.Now;
        await _dbContext.SaveChangesAsync();

        // 生成JWT令牌
        var token = _jwtHelper.GenerateToken(user.Id, user.Username);
        return ResponseDto<string>.Success(token, "登录成功");
    }

    // 用户注册
    public async Task<ResponseDto> Register(RegisterRequest request)
    {
        // 检查邮箱/用户名是否已存在
        if (await _dbContext.Users.AnyAsync(u => u.Email == request.Email))
        {
            return( ResponseDto) ResponseDto.Fail("邮箱已被注册", 400);
        }

        if (await _dbContext.Users.AnyAsync(u => u.Username == request.Username))
        {
            return (ResponseDto) ResponseDto.Fail("用户名已被占用", 400);
        }

        // 创建用户（密码MD5加密）
        var user = new User
        {
            Username = request.Username,
            Email = request.Email,
            Password = MD5Helper.MD5Encrypt(request.Password),
            CreateTime = DateTime.Now
        };

        _dbContext.Users.Add(user);
        await _dbContext.SaveChangesAsync();

        return (ResponseDto) ResponseDto.Success("注册成功");
    }

    // 找回密码（发送验证码）
    public async Task<ResponseDto> ForgotPassword(string email)
    {
        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Email == email);
        if (user == null)
        {
            return (ResponseDto)ResponseDto.Fail("邮箱未注册", 404);
        }

        // TODO: 实际项目中添加发送验证码逻辑（如SMTP邮件/短信）
        Console.WriteLine($"向{email}发送验证码：123456"); // 测试用

        return ResponseDto.Success("验证码已发送至您的邮箱");
    }
}