using Microsoft.AspNetCore.Mvc;
using Server.Api.Common;

namespace Server.Api.Controllers;

[ApiController]
[Route("api/health")]
public class HealthController : ControllerBase
{
    [HttpGet]
    public IActionResult Get() => Ok(ApiResult.Ok("healthy"));
}
