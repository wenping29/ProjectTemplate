using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Server.Api.Common;
using Server.Api.DTOs;
using Server.Api.Services;

namespace Server.Api.Controllers;

[ApiController]
[Route("api/system-config")]
[Authorize]
public class SystemConfigController : ControllerBase
{
    private readonly ISystemConfigService _svc;
    public SystemConfigController(ISystemConfigService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List(string? group) => Ok(ApiResult.Ok(await _svc.ListAsync(group)));

    // 对外公开配置（无需登录）：站点名称、Logo、是否开放注册等
    [HttpGet("public")]
    [AllowAnonymous]
    public async Task<IActionResult> Public() => Ok(ApiResult.Ok(await _svc.PublicAsync()));

    [HttpGet("by-key/{key}")]
    public async Task<IActionResult> ByKey(string key) =>
        Ok(await _svc.GetByKeyAsync(key) is { } r ? ApiResult.Ok(r) : ApiResult.Fail(404, "未找到"));

    [HttpPost]
    public async Task<IActionResult> Upsert(SystemConfigUpsertRequest req) => Ok(ApiResult.Ok(await _svc.UpsertAsync(req)));

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id) =>
        Ok(await _svc.DeleteAsync(id) ? ApiResult.Ok() : ApiResult.Fail(404, "未找到"));
}
