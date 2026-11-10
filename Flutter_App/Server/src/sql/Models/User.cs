using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChatServer.Models;

[Table("users")]
public class User
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Column("username")]
    [Required]
    [MaxLength(50)]
    public string Username { get; set; } = string.Empty;

    [Column("email")]
    [Required]
    [MaxLength(100)]
    public string Email { get; set; } = string.Empty;

    [Column("password")]
    [Required]
    [MaxLength(32)] // MD5加密后32位
    public string Password { get; set; } = string.Empty;

    [Column("avatar")]
    [MaxLength(200)]
    public string? Avatar { get; set; } // 头像URL

    [Column("create_time")]
    public DateTime CreateTime { get; set; } = DateTime.Now;

    [Column("last_login_time")]
    public DateTime? LastLoginTime { get; set; }
    //Phone
    [Column("Phone")]
    [MaxLength(200)]
    public string? Phone { get; set; } //
}