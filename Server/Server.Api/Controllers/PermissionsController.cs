using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Server.Api.Common;
using Server.Api.DTOs;
using Server.Api.Services;

namespace Server.Api.Controllers;

[ApiController]
[Route("api/permissions")]
[Authorize]
public class PermissionsController : ControllerBase
{
    private readonly IPermissionService _svc;
    public PermissionsController(IPermissionService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List() => Ok(ApiResult.Ok(await _svc.ListAsync()));

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> Get(Guid id) =>
        Ok(await _svc.GetAsync(id) is { } r ? ApiResult.Ok(r) : ApiResult.Fail(404, "未找到"));

    [HttpPost]
    public async Task<IActionResult> Create(PermissionUpsertRequest req) => Ok(ApiResult.Ok(await _svc.CreateAsync(req)));

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, PermissionUpsertRequest req) =>
        Ok(await _svc.UpdateAsync(id, req) ? ApiResult.Ok() : ApiResult.Fail(404, "未找到"));

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id) =>
        Ok(await _svc.DeleteAsync(id) ? ApiResult.Ok() : ApiResult.Fail(404, "未找到"));
}
