using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Server.Api.Models;

/// <summary>菜单（菜单管理；App 底部菜单亦来源于此）</summary>
public class Menu
{
    public Guid Id { get; set; }
    public Guid? ParentId { get; set; }
    public Menu? Parent { get; set; }

    [Required, MaxLength(50)]
    public string Name { get; set; } = string.Empty;

    /// <summary>1=目录 2=菜单 3=按钮</summary>
    public short Type { get; set; } = 2;

    [MaxLength(200)]
    public string? Path { get; set; }

    [MaxLength(50)]
    public string? Icon { get; set; }

    [MaxLength(200)]
    public string? Component { get; set; }

    [MaxLength(100)]
    public string? Permission { get; set; }

    public int Sort { get; set; } = 0;

    public short Status { get; set; } = 1;

    [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
    public DateTime CreatedAt { get; set; }

    [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
    public DateTime UpdatedAt { get; set; }

    public ICollection<Menu> Children { get; set; } = new List<Menu>();
    public ICollection<Permission> Permissions { get; set; } = new List<Permission>();
    public ICollection<RoleMenu> RoleMenus { get; set; } = new List<RoleMenu>();
}

/// <summary>功能/权限（功能管理；按钮级）</summary>
public class Permission
{
    public Guid Id { get; set; }

    [Required, MaxLength(100)]
    public string Code { get; set; } = string.Empty;

    [Required, MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    public Guid? MenuId { get; set; }
    public Menu? Menu { get; set; }

    [MaxLength(200)]
    public string? Description { get; set; }

    [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
    public DateTime CreatedAt { get; set; }

    [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
    public DateTime UpdatedAt { get; set; }

    public ICollection<RolePermission> RolePermissions { get; set; } = new List<RolePermission>();
}

/// <summary>角色-菜单</summary>
public class RoleMenu
{
    public Guid RoleId { get; set; }
    public Role? Role { get; set; }
    public Guid MenuId { get; set; }
    public Menu? Menu { get; set; }
}

/// <summary>角色-功能</summary>
public class RolePermission
{
    public Guid RoleId { get; set; }
    public Role? Role { get; set; }
    public Guid PermissionId { get; set; }
    public Permission? Permission { get; set; }
}

/// <summary>系统配置（系统配置；键值对 + 分组）</summary>
public class SystemConfig
{
    public Guid Id { get; set; }

    [Required, MaxLength(100)]
    public string ConfigKey { get; set; } = string.Empty;

    public string? ConfigValue { get; set; }

    [MaxLength(50)]
    public string? ConfigGroup { get; set; }

    /// <summary>1=对外可查</summary>
    public short IsPublic { get; set; } = 0;

    [MaxLength(200)]
    public string? Description { get; set; }

    [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
    public DateTime CreatedAt { get; set; }

    [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
    public DateTime UpdatedAt { get; set; }
}
