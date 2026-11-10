using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace ChatServer.Utils;

public class JwtHelper
{
    private readonly IConfiguration _configuration;

    public JwtHelper(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    // 生成JWT令牌
    public string GenerateToken(int userId, string username)
    {
        var jwtSettings = _configuration.GetSection("JwtSettings");
        var secretKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings["SecretKey"]!));
        var credentials = new SigningCredentials(secretKey, SecurityAlgorithms.HmacSha256);

        // 声明信息
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, userId.ToString()),
            new Claim(ClaimTypes.Name, username),
            new Claim(JwtRegisteredClaimNames.Iat, DateTime.Now.Millisecond.ToString()),
            new Claim(JwtRegisteredClaimNames.Exp, DateTime.Now.AddHours(int.Parse(jwtSettings["ExpiresHours"]!)).ToUniversalTime().ToString())
        };

        // 生成令牌
        var token = new JwtSecurityToken(
            issuer: jwtSettings["Issuer"],
            audience: jwtSettings["Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddHours(2), // 添加过期时间
            //expires: DateTime.Now.AddHours(int.Parse(jwtSettings["ExpiresHours"]!)),
            signingCredentials: credentials
        );

        string tokestr= new JwtSecurityTokenHandler().WriteToken(token);

        // 调试：打印生成的Token，确认有两个点
        Console.WriteLine($"服务端生成的Token：{tokestr}");
        Console.WriteLine($"Token是否包含两个点：{tokestr.Split('.').Length == 3}");

        return tokestr;
    }
}