using Microsoft.EntityFrameworkCore;
using Server.Api.Data;
using Server.Api.DTOs;
using Server.Api.Models;

namespace Server.Api.Services;

/// <summary>树形菜单节点（供前端渲染，含 App 底部菜单）</summary>
public record MenuNode(
    Guid Id, Guid? ParentId, string Name, short Type, string? Path, string? Icon,
    string? Component, string? Permission, int Sort, short Status, List<MenuNode> Children);

public interface IMenuService
{
    Task<List<MenuDto>> ListAsync();
    Task<List<MenuNode>> TreeAsync();
    Task<MenuDto?> GetAsync(Guid id);
    Task<MenuDto> CreateAsync(MenuUpsertRequest req);
    Task<bool> UpdateAsync(Guid id, MenuUpsertRequest req);
    Task<bool> DeleteAsync(Guid id);
}

public class MenuService : IMenuService
{
    private readonly AppDbContext _db;
    public MenuService(AppDbContext db) => _db = db;

    public async Task<List<MenuDto>> ListAsync() =>
        await _db.Menus.OrderBy(m => m.Sort).ThenBy(m => m.Name)
            .Select(m => new MenuDto(m.Id, m.ParentId, m.Name, m.Type, m.Path, m.Icon, m.Component, m.Permission, m.Sort, m.Status))
            .ToListAsync();

    public async Task<List<MenuNode>> TreeAsync()
    {
        var all = await _db.Menus.OrderBy(m => m.Sort).ToListAsync();
        var dict = all.ToDictionary(m => m.Id, m => new MenuNode(
            m.Id, m.ParentId, m.Name, m.Type, m.Path, m.Icon, m.Component, m.Permission, m.Sort, m.Status, new List<MenuNode>()));
        var roots = new List<MenuNode>();
        foreach (var node in dict.Values)
        {
            if (node.ParentId is { } pid && dict.TryGetValue(pid, out var parent))
                parent.Children.Add(node);
            else
                roots.Add(node);
        }
        return roots;
    }

    public async Task<MenuDto?> GetAsync(Guid id) =>
        await _db.Menus.Where(m => m.Id == id)
            .Select(m => new MenuDto(m.Id, m.ParentId, m.Name, m.Type, m.Path, m.Icon, m.Component, m.Permission, m.Sort, m.Status))
            .FirstOrDefaultAsync();

    public async Task<MenuDto> CreateAsync(MenuUpsertRequest req)
    {
        if (req.ParentId is { } pid && !await _db.Menus.AnyAsync(m => m.Id == pid))
            throw new InvalidOperationException("父菜单不存在");
        var menu = new Menu
        {
            ParentId = req.ParentId,
            Name = req.Name,
            Type = req.Type,
            Path = req.Path,
            Icon = req.Icon,
            Component = req.Component,
            Permission = req.Permission,
            Sort = req.Sort,
            Status = req.Status
        };
        _db.Menus.Add(menu);
        await _db.SaveChangesAsync();
        return new MenuDto(menu.Id, menu.ParentId, menu.Name, menu.Type, menu.Path, menu.Icon, menu.Component, menu.Permission, menu.Sort, menu.Status);
    }

    public async Task<bool> UpdateAsync(Guid id, MenuUpsertRequest req)
    {
        var menu = await _db.Menus.FindAsync(id);
        if (menu is null) return false;
        menu.ParentId = req.ParentId;
        menu.Name = req.Name;
        menu.Type = req.Type;
        menu.Path = req.Path;
        menu.Icon = req.Icon;
        menu.Component = req.Component;
        menu.Permission = req.Permission;
        menu.Sort = req.Sort;
        menu.Status = req.Status;
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(Guid id)
    {
        var menu = await _db.Menus.FindAsync(id);
        if (menu is null) return false;
        _db.Menus.Remove(menu);   // 生产环境可在菜单含子项时改为禁用
        await _db.SaveChangesAsync();
        return true;
    }
}
