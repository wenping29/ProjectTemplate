using Microsoft.EntityFrameworkCore;
using Server.Api.Data;
using Server.Api.DTOs;
using Server.Api.Models;

namespace Server.Api.Services;

public interface IUserService
{
    Task<List<UserDto>> ListAsync(string? q);
    Task<UserDto?> GetAsync(Guid id);
    Task<UserDto> CreateAsync(UserUpsertRequest req);
    Task<bool> UpdateAsync(Guid id, UserUpsertRequest req);
    Task<bool> DeleteAsync(Guid id);
    Task<bool> UpdateProfileAsync(Guid id, UpdateProfileRequest req);
}

public class UserService : IUserService
{
    private readonly AppDbContext _db;
    public UserService(AppDbContext db) => _db = db;

    public async Task<List<UserDto>> ListAsync(string? q)
    {
        var qry = _db.Users.Where(u => u.DeletedAt == null);
        if (!string.IsNullOrWhiteSpace(q))
            qry = qry.Where(u => u.Username.Contains(q) || u.Email.Contains(q) ||
                                 (u.DisplayName != null && u.DisplayName.Contains(q)));
        return await qry.OrderByDescending(u => u.CreatedAt)
            .Select(u => ToDto(u)).ToListAsync();
    }

    public async Task<UserDto?> GetAsync(Guid id) =>
        await _db.Users.Where(u => u.Id == id && u.DeletedAt == null)
            .Select(u => ToDto(u)).FirstOrDefaultAsync();

    public async Task<UserDto> CreateAsync(UserUpsertRequest req)
    {
        if (await _db.Users.AnyAsync(u => u.Username == req.Username || u.Email == req.Email))
            throw new InvalidOperationException("用户名或邮箱已存在");
        if (!await _db.Roles.AnyAsync(r => r.Id == req.RoleId))
            throw new InvalidOperationException("指定的角色不存在");

        var user = new User
        {
            Username = req.Username,
            Email = req.Email,
            DisplayName = req.DisplayName,
            AvatarUrl = req.AvatarUrl,
            Phone = req.Phone,
            RoleId = req.RoleId,
            Status = req.Status,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(string.IsNullOrWhiteSpace(req.Password) ? "Pass@123" : req.Password)
        };
        _db.Users.Add(user);
        await _db.SaveChangesAsync();
        return ToDto(user);
    }

    public async Task<bool> UpdateAsync(Guid id, UserUpsertRequest req)
    {
        var user = await _db.Users.FindAsync(id);
        if (user is null || user.DeletedAt != null) return false;
        user.Username = req.Username;
        user.Email = req.Email;
        user.DisplayName = req.DisplayName;
        user.AvatarUrl = req.AvatarUrl;
        user.Phone = req.Phone;
        user.RoleId = req.RoleId;
        user.Status = req.Status;
        if (!string.IsNullOrWhiteSpace(req.Password))
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(req.Password);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(Guid id)
    {
        var user = await _db.Users.FindAsync(id);
        if (user is null || user.DeletedAt != null) return false;
        user.DeletedAt = DateTime.UtcNow;          // 软删除
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> UpdateProfileAsync(Guid id, UpdateProfileRequest req)
    {
        var user = await _db.Users.FindAsync(id);
        if (user is null || user.DeletedAt != null) return false;
        user.DisplayName = req.DisplayName ?? user.DisplayName;
        user.AvatarUrl = req.AvatarUrl ?? user.AvatarUrl;
        user.Phone = req.Phone ?? user.Phone;
        await _db.SaveChangesAsync();
        return true;
    }

    private static UserDto ToDto(User u) =>
        new(u.Id, u.Username, u.Email, u.DisplayName, u.AvatarUrl, u.Phone, u.RoleId, u.Status);
}
