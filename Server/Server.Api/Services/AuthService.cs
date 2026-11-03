using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Server.Api.Common;
using Server.Api.Data;
using Server.Api.DTOs;
using Server.Api.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace Server.Api.Services;

public interface IAuthService
{
    Task<AuthResult?> LoginAsync(LoginRequest req);
    Task<AuthResult?> RegisterAsync(RegisterRequest req);
}

public class AuthService : IAuthService
{
    private readonly AppDbContext _db;
    private readonly JwtOptions _jwt;

    public AuthService(AppDbContext db, JwtOptions jwt)
    {
        _db = db;
        _jwt = jwt;
    }

    public async Task<AuthResult?> LoginAsync(LoginRequest req)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Username == req.Username && u.DeletedAt == null);
        if (user is null || user.Status != 1) return null;
        if (!BCrypt.Net.BCrypt.Verify(req.Password, user.PasswordHash)) return null;

        user.LastLoginAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return new AuthResult(GenerateToken(user), user.Id, user.Username, user.DisplayName, user.RoleId);
    }

    public async Task<AuthResult?> RegisterAsync(RegisterRequest req)
    {
        if (await _db.Users.AnyAsync(u => u.Username == req.Username || u.Email == req.Email))
            return null;

        var role = await _db.Roles.FirstOrDefaultAsync(r => r.Name == "user")
                   ?? throw new InvalidOperationException("默认角色 user 不存在，请先执行 DB 种子脚本");

        var user = new User
        {
            Username = req.Username,
            Email = req.Email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(req.Password),
            DisplayName = req.DisplayName,
            Phone = req.Phone,
            RoleId = role.Id,
            Status = 1
        };
        _db.Users.Add(user);
        await _db.SaveChangesAsync();
        return new AuthResult(GenerateToken(user), user.Id, user.Username, user.DisplayName, user.RoleId);
    }

    private string GenerateToken(User u)
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, u.Id.ToString()),
            new Claim(ClaimTypes.Name, u.Username),
            new Claim(ClaimTypes.Role, u.RoleId.ToString())
        };
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwt.Key));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var token = new JwtSecurityToken(
            _jwt.Issuer, _jwt.Audience, claims,
            expires: DateTime.UtcNow.AddMinutes(_jwt.ExpiresMinutes),
            signingCredentials: creds);
        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
