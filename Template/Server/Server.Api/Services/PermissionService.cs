using Microsoft.EntityFrameworkCore;
using Server.Api.Data;
using Server.Api.DTOs;
using Server.Api.Models;

namespace Server.Api.Services;

public interface IPermissionService
{
    Task<List<PermissionDto>> ListAsync();
    Task<PermissionDto?> GetAsync(Guid id);
    Task<PermissionDto> CreateAsync(PermissionUpsertRequest req);
    Task<bool> UpdateAsync(Guid id, PermissionUpsertRequest req);
    Task<bool> DeleteAsync(Guid id);
}

public class PermissionService : IPermissionService
{
    private readonly AppDbContext _db;
    public PermissionService(AppDbContext db) => _db = db;

    public async Task<List<PermissionDto>> ListAsync() =>
        await _db.Permissions.OrderBy(p => p.Code)
            .Select(p => new PermissionDto(p.Id, p.Code, p.Name, p.MenuId, p.Description))
            .ToListAsync();

    public async Task<PermissionDto?> GetAsync(Guid id) =>
        await _db.Permissions.Where(p => p.Id == id)
            .Select(p => new PermissionDto(p.Id, p.Code, p.Name, p.MenuId, p.Description))
            .FirstOrDefaultAsync();

    public async Task<PermissionDto> CreateAsync(PermissionUpsertRequest req)
    {
        if (await _db.Permissions.AnyAsync(p => p.Code == req.Code))
            throw new InvalidOperationException("功能编码已存在");
        var perm = new Permission
        {
            Code = req.Code,
            Name = req.Name,
            MenuId = req.MenuId,
            Description = req.Description
        };
        _db.Permissions.Add(perm);
        await _db.SaveChangesAsync();
        return new PermissionDto(perm.Id, perm.Code, perm.Name, perm.MenuId, perm.Description);
    }

    public async Task<bool> UpdateAsync(Guid id, PermissionUpsertRequest req)
    {
        var perm = await _db.Permissions.FindAsync(id);
        if (perm is null) return false;
        perm.Code = req.Code;
        perm.Name = req.Name;
        perm.MenuId = req.MenuId;
        perm.Description = req.Description;
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(Guid id)
    {
        var perm = await _db.Permissions.FindAsync(id);
        if (perm is null) return false;
        _db.Permissions.Remove(perm);
        await _db.SaveChangesAsync();
        return true;
    }
}
