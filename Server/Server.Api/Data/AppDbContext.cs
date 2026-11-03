using Microsoft.EntityFrameworkCore;
using Server.Api.Models;

namespace Server.Api.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Role> Roles => Set<Role>();
    public DbSet<User> Users => Set<User>();
    public DbSet<Menu> Menus => Set<Menu>();
    public DbSet<Permission> Permissions => Set<Permission>();
    public DbSet<RoleMenu> RoleMenus => Set<RoleMenu>();
    public DbSet<RolePermission> RolePermissions => Set<RolePermission>();
    public DbSet<SystemConfig> SystemConfigs => Set<SystemConfig>();
    public DbSet<Product> Products => Set<Product>();

    protected override void OnModelCreating(ModelBuilder b)
    {
        // 表名对齐 DB/ 下的建表脚本（snake_case + 复数）
        b.Entity<Role>().ToTable("roles");
        b.Entity<User>().ToTable("users");
        b.Entity<Menu>().ToTable("menus");
        b.Entity<Permission>().ToTable("permissions");
        b.Entity<RoleMenu>().ToTable("role_menus");
        b.Entity<RolePermission>().ToTable("role_permissions");
        b.Entity<SystemConfig>().ToTable("system_config");
        b.Entity<Product>().ToTable("products");

        // 列名统一 snake_case
        foreach (var entity in b.Model.GetEntityTypes())
        {
            foreach (var prop in entity.GetProperties())
                prop.SetColumnName(ToSnakeCase(prop.Name));
        }

        // 联合主键
        b.Entity<RoleMenu>().HasKey(x => new { x.RoleId, x.MenuId });
        b.Entity<RolePermission>().HasKey(x => new { x.RoleId, x.PermissionId });

        // 关系
        b.Entity<RoleMenu>().HasOne(x => x.Role).WithMany(x => x.RoleMenus).HasForeignKey(x => x.RoleId);
        b.Entity<RoleMenu>().HasOne(x => x.Menu).WithMany(x => x.RoleMenus).HasForeignKey(x => x.MenuId);
        b.Entity<RolePermission>().HasOne(x => x.Role).WithMany(x => x.RolePermissions).HasForeignKey(x => x.RoleId);
        b.Entity<RolePermission>().HasOne(x => x.Permission).WithMany(x => x.RolePermissions).HasForeignKey(x => x.PermissionId);
        b.Entity<Menu>().HasOne(x => x.Parent).WithMany(x => x.Children).HasForeignKey(x => x.ParentId);
    }

    private static string ToSnakeCase(string name)
    {
        // 简易 PascalCase -> snake_case
        var sb = new System.Text.StringBuilder();
        for (int i = 0; i < name.Length; i++)
        {
            var c = name[i];
            if (char.IsUpper(c))
            {
                if (i > 0) sb.Append('_');
                sb.Append(char.ToLowerInvariant(c));
            }
            else sb.Append(c);
        }
        return sb.ToString();
    }
}
