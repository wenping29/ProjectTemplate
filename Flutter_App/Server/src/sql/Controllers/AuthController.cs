using ChatServer.DTOs;
using ChatServer.Services;
using Microsoft.AspNetCore.Mvc;

namespace ChatServer.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly AuthService _authService;

    public AuthController(AuthService authService)
    {
        _authService = authService;
    }

    // 登录接口 POST /api/Auth/Login
    [HttpPost("Login")]
    public async Task<ActionResult<ResponseDto<string>>> Login([FromBody] LoginRequest request)
    {
        var result = await _authService.Login(request);
        return Ok(result);
    }
    // 注册接口 POST /api/Auth/Register
    [HttpPost("Register")]
    public async Task<ActionResult<ResponseDto>> Register([FromBody] RegisterRequest request)
    {
        var result = await _authService.Register(request);
        return Ok(result);
    }
    // 找回密码接口 POST /api/Auth/ForgotPassword
    [HttpPost("ForgotPassword")]
    public async Task<ActionResult<ResponseDto>> ForgotPassword([FromBody] string email)
    {
        var result = await _authService.ForgotPassword(email);
        return Ok(result);
    }
}