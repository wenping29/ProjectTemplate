using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Server.Api.Common;
using Server.Api.DTOs;
using Server.Api.Services;

namespace Server.Api.Controllers;

[ApiController]
[Route("api/menus")]
[Authorize]
public class MenusController : ControllerBase
{
    private readonly IMenuService _svc;
    public MenusController(IMenuService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List() => Ok(ApiResult.Ok(await _svc.ListAsync()));

    // 树形结构（后台菜单树 / App 底部菜单均可消费）
    [HttpGet("tree")]
    public async Task<IActionResult> Tree() => Ok(ApiResult.Ok(await _svc.TreeAsync()));

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> Get(Guid id) =>
        Ok(await _svc.GetAsync(id) is { } r ? ApiResult.Ok(r) : ApiResult.Fail(404, "未找到"));

    [HttpPost]
    public async Task<IActionResult> Create(MenuUpsertRequest req) => Ok(ApiResult.Ok(await _svc.CreateAsync(req)));

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, MenuUpsertRequest req) =>
        Ok(await _svc.UpdateAsync(id, req) ? ApiResult.Ok() : ApiResult.Fail(404, "未找到"));

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id) =>
        Ok(await _svc.DeleteAsync(id) ? ApiResult.Ok() : ApiResult.Fail(404, "未找到"));
}
