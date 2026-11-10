using Microsoft.EntityFrameworkCore;
using ChatServer.Models;
using ChatServer.Models.Entities;

namespace ChatServer.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    // 定义DbSet对应数据库表
    public DbSet<User> Users { get; set; }
    public DbSet<ChatSession> ChatSessions { get; set; }
    public DbSet<ChatMessage> ChatMessages { get; set; }
    // 新增：收藏表
    public DbSet<Collection> Collections { get; set; }
    // 好友表
    public DbSet<Friend> Friends { get; set; }

    // 朋友圈表
        public DbSet<Moment> Moments { get; set; }
        // 其他表（Users/Friends/Collections 等）已存在则无需重复添加

     

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {

        modelBuilder.Entity<Moment>()
            .HasIndex(m => m.UserId); // 按发布者ID索引
        modelBuilder.Entity<Moment>()
            .HasIndex(m => m.CreateTime); // 按发布时间索引
        modelBuilder.Entity<Moment>()
            .HasIndex(m => m.Visibility); // 按可见范围索引

        // 配置索引（优化查询）
        modelBuilder.Entity<ChatSession>()
            .HasIndex(s => s.SessionId)
            .IsUnique();
        
        modelBuilder.Entity<ChatMessage>()
            .HasIndex(m => m.SessionId);
        
        modelBuilder.Entity<User>()
            .HasIndex(u => u.Email)
            .IsUnique();
        
        modelBuilder.Entity<User>()
            .HasIndex(u => u.Username)
            .IsUnique();

        // 可选：配置索引（优化查询性能）
        modelBuilder.Entity<Collection>()
            .HasIndex(c => c.UserId); // 按用户ID索引
        // 好友表索引优化
        modelBuilder.Entity<Friend>()
            .HasIndex(f => new { f.UserId, f.FriendUserId }) // 复合索引，优化查询
            .IsUnique(); // 避免重复添加好友
        modelBuilder.Entity<Friend>()
            .HasIndex(f => f.Status); // 状态索引
    }
}