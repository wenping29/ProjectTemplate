using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChatServer.Models;

[Table("chat_sessions")]
public class ChatSession
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Column("session_id")]
    [Required]
    [MaxLength(50)]
    public string SessionId { get; set; } = string.Empty; // 会话唯一标识（如user1_user2）

    [Column("user_id1")]
    public int UserId1 { get; set; } // 参与者1

    [Column("user_id2")]
    public int UserId2 { get; set; } // 参与者2（群聊为0）

    [Column("session_name")]
    [MaxLength(50)]
    public string SessionName { get; set; } = string.Empty; // 会话名称

    [Column("last_message")]
    [MaxLength(200)]
    public string? LastMessage { get; set; } // 最后一条消息

    [Column("last_message_time")]
    public DateTime? LastMessageTime { get; set; } // 最后消息时间

    [Column("unread_count")]
    public int UnreadCount { get; set; } = 0; // 未读消息数

    [Column("is_group")]
    public bool IsGroup { get; set; } = false; // 是否群聊
}