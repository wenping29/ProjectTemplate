using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Server.Api.Common;
using Server.Api.DTOs;
using Server.Api.Services;

namespace Server.Api.Controllers;

[ApiController]
[Route("api/users")]
[Authorize]
public class UsersController : ControllerBase
{
    private readonly IUserService _svc;
    public UsersController(IUserService svc) => _svc = svc;

    private Guid CurrentUserId => Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    [HttpGet]
    public async Task<IActionResult> List(string? q) => Ok(ApiResult.Ok(await _svc.ListAsync(q)));

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> Get(Guid id) =>
        Ok(await _svc.GetAsync(id) is { } r ? ApiResult.Ok(r) : ApiResult.Fail(404, "未找到"));

    [HttpPost]
    public async Task<IActionResult> Create(UserUpsertRequest req) => Ok(ApiResult.Ok(await _svc.CreateAsync(req)));

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, UserUpsertRequest req) =>
        Ok(await _svc.UpdateAsync(id, req) ? ApiResult.Ok() : ApiResult.Fail(404, "未找到"));

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id) =>
        Ok(await _svc.DeleteAsync(id) ? ApiResult.Ok() : ApiResult.Fail(404, "未找到"));

    // 修改个人信息（App / Web 通用）
    [HttpPut("me/profile")]
    public async Task<IActionResult> UpdateProfile(UpdateProfileRequest req) =>
        Ok(await _svc.UpdateProfileAsync(CurrentUserId, req) ? ApiResult.Ok() : ApiResult.Fail(404, "未找到"));
}
