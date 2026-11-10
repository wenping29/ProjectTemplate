using Microsoft.EntityFrameworkCore;
using Server.Api.Data;
using Server.Api.DTOs;
using Server.Api.Models;

namespace Server.Api.Services;

public interface IRoleService
{
    Task<List<RoleDto>> ListAsync();
    Task<RoleDto?> GetAsync(Guid id);
    Task<RoleDto> CreateAsync(RoleUpsertRequest req);
    Task<bool> UpdateAsync(Guid id, RoleUpsertRequest req);
    Task<bool> DeleteAsync(Guid id);
    Task<bool> GrantAsync(Guid id, RoleGrantRequest req);
}

public class RoleService : IRoleService
{
    private readonly AppDbContext _db;
    public RoleService(AppDbContext db) => _db = db;

    public async Task<List<RoleDto>> ListAsync() =>
        await _db.Roles.OrderBy(r => r.Name)
            .Select(r => new RoleDto(r.Id, r.Name, r.Description, r.CreatedAt)).ToListAsync();

    public async Task<RoleDto?> GetAsync(Guid id) =>
        await _db.Roles.Where(r => r.Id == id)
            .Select(r => new RoleDto(r.Id, r.Name, r.Description, r.CreatedAt)).FirstOrDefaultAsync();

    public async Task<RoleDto> CreateAsync(RoleUpsertRequest req)
    {
        var role = new Role { Name = req.Name, Description = req.Description };
        _db.Roles.Add(role);
        await _db.SaveChangesAsync();
        return new RoleDto(role.Id, role.Name, role.Description, role.CreatedAt);
    }

    public async Task<bool> UpdateAsync(Guid id, RoleUpsertRequest req)
    {
        var role = await _db.Roles.FindAsync(id);
        if (role is null) return false;
        role.Name = req.Name;
        role.Description = req.Description;
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(Guid id)
    {
        var role = await _db.Roles.FindAsync(id);
        if (role is null) return false;
        _db.Roles.Remove(role);
        await _db.SaveChangesAsync();
        return true;
    }

    // 角色授权：覆盖式设置菜单与功能
    public async Task<bool> GrantAsync(Guid id, RoleGrantRequest req)
    {
        var role = await _db.Roles
            .Include(r => r.RoleMenus)
            .Include(r => r.RolePermissions)
            .FirstOrDefaultAsync(r => r.Id == id);
        if (role is null) return false;

        role.RoleMenus = req.MenuIds
            .Distinct().Select(m => new RoleMenu { RoleId = id, MenuId = m }).ToList();
        role.RolePermissions = req.PermissionIds
            .Distinct().Select(p => new RolePermission { RoleId = id, PermissionId = p }).ToList();

        await _db.SaveChangesAsync();
        return true;
    }
}
