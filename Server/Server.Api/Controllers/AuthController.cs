using Microsoft.AspNetCore.Mvc;
using Server.Api.Common;
using Server.Api.DTOs;
using Server.Api.Services;

namespace Server.Api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _svc;
    public AuthController(IAuthService svc) => _svc = svc;

    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginRequest req)
    {
        var r = await _svc.LoginAsync(req);
        return r is null ? Ok(ApiResult.Fail(401, "用户名或密码错误")) : Ok(ApiResult.Ok(r));
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterRequest req)
    {
        var r = await _svc.RegisterAsync(req);
        return r is null ? Ok(ApiResult.Fail(409, "用户名或邮箱已存在")) : Ok(ApiResult.Ok(r));
    }
}
