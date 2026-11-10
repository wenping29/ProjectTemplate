using System.ComponentModel.DataAnnotations;

namespace ChatServer.DTOs;

public class LoginRequest
{
    [Required(ErrorMessage = "账号/邮箱不能为空")]
    public string Account { get; set; } = string.Empty;

    [Required(ErrorMessage = "密码不能为空")]
    public string Password { get; set; } = string.Empty;
}