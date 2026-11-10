using System.ComponentModel.DataAnnotations;

namespace ChatServer.DTOs;

public class SendMessageRequest
{
    [Required(ErrorMessage = "会话ID不能为空")]
    public string SessionId { get; set; } = string.Empty;

    [Required(ErrorMessage = "消息内容不能为空")]
    public string Content { get; set; } = string.Empty;
}