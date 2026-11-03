using Microsoft.EntityFrameworkCore;
using Server.Api.Data;
using Server.Api.DTOs;

namespace Server.Api.Services;

public interface ISystemConfigService
{
    Task<List<SystemConfigDto>> ListAsync(string? group);
    Task<SystemConfigDto?> GetByKeyAsync(string key);
    Task<Dictionary<string, string?>> PublicAsync();
    Task<SystemConfigDto> UpsertAsync(SystemConfigUpsertRequest req);
    Task<bool> DeleteAsync(Guid id);
}

public class SystemConfigService : ISystemConfigService
{
    private readonly AppDbContext _db;
    public SystemConfigService(AppDbContext db) => _db = db;

    public async Task<List<SystemConfigDto>> ListAsync(string? group)
    {
        var qry = _db.SystemConfigs.AsQueryable();
        if (!string.IsNullOrWhiteSpace(group))
            qry = qry.Where(c => c.ConfigGroup == group);
        return await qry.OrderBy(c => c.ConfigGroup).ThenBy(c => c.ConfigKey)
            .Select(c => new SystemConfigDto(c.Id, c.ConfigKey, c.ConfigValue, c.ConfigGroup, c.IsPublic, c.Description))
            .ToListAsync();
    }

    public async Task<SystemConfigDto?> GetByKeyAsync(string key) =>
        await _db.SystemConfigs.Where(c => c.ConfigKey == key)
            .Select(c => new SystemConfigDto(c.Id, c.ConfigKey, c.ConfigValue, c.ConfigGroup, c.IsPublic, c.Description))
            .FirstOrDefaultAsync();

    public async Task<Dictionary<string, string?>> PublicAsync() =>
        await _db.SystemConfigs.Where(c => c.IsPublic == 1)
            .ToDictionaryAsync(c => c.ConfigKey, c => c.ConfigValue);

    public async Task<SystemConfigDto> UpsertAsync(SystemConfigUpsertRequest req)
    {
        var existing = await _db.SystemConfigs.FirstOrDefaultAsync(c => c.ConfigKey == req.ConfigKey);
        if (existing is null)
        {
            var cfg = new SystemConfig
            {
                ConfigKey = req.ConfigKey,
                ConfigValue = req.ConfigValue,
                ConfigGroup = req.ConfigGroup,
                IsPublic = req.IsPublic,
                Description = req.Description
            };
            _db.SystemConfigs.Add(cfg);
            await _db.SaveChangesAsync();
            return ToDto(cfg);
        }
        existing.ConfigValue = req.ConfigValue;
        existing.ConfigGroup = req.ConfigGroup;
        existing.IsPublic = req.IsPublic;
        existing.Description = req.Description;
        await _db.SaveChangesAsync();
        return ToDto(existing);
    }

    public async Task<bool> DeleteAsync(Guid id)
    {
        var cfg = await _db.SystemConfigs.FindAsync(id);
        if (cfg is null) return false;
        _db.SystemConfigs.Remove(cfg);
        await _db.SaveChangesAsync();
        return true;
    }

    private static SystemConfigDto ToDto(SystemConfig c) =>
        new(c.Id, c.ConfigKey, c.ConfigValue, c.ConfigGroup, c.IsPublic, c.Description);
}
