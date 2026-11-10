using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChatServer.Models;

[Table("chat_messages")]
public class ChatMessage
{
    [Key]
    [Column("id")]
    public long Id { get; set; }

    [Column("session_id")]
    [Required]
    [MaxLength(50)]
    public string SessionId { get; set; } = string.Empty; // 关联会话ID

    [Column("sender_id")]
    public int SenderId { get; set; } // 发送者ID

    [Column("content")]
    [Required]
    public string Content { get; set; } = string.Empty; // 消息内容

    [Column("send_time")]
    public DateTime SendTime { get; set; } = DateTime.Now; // 发送时间

    [Column("is_read")]
    public bool IsRead { get; set; } = false; // 是否已读
}