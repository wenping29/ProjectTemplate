using ChatServer.DAL;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace ChatServer.Controllers
{
    /// <summary>
    /// 朋友圈API控制器
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize] // 需登录才能访问
    public class MomentController : ControllerBase
    {
        private readonly MomentDAL _momentDAL;
        private readonly ILogger<MomentController> _logger;

        public MomentController(
            MomentDAL momentDAL,
            ILogger<MomentController> logger)
        {
            _momentDAL = momentDAL;
            _logger = logger;
        }

        /// <summary>
        /// 获取当前用户可见的朋友圈列表（分页）
        /// </summary>
        /// <param name="pageIndex">页码（默认1）</param>
        /// <param name="pageSize">每页条数（默认10）</param>
        /// <returns>朋友圈列表</returns>
        [HttpGet("MyMomentList")]
        public async Task<IActionResult> GetMyMomentList([FromQuery] int pageIndex = 1,[FromQuery] int pageSize = 10)
        {
            try
            {
                // 1. 从JWT令牌解析当前用户ID
                var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userIdStr) || !int.TryParse(userIdStr, out int currentUserId))
                {
                    _logger.LogWarning("解析用户ID失败：{userIdStr}", userIdStr);
                    return BadRequest(new { code = 400, message = "用户ID无效", data = "" });
                }

                // 2. 校验分页参数
                if (pageIndex < 1) pageIndex = 1;
                if (pageSize < 1 || pageSize > 20) pageSize = 10;

                // 3. 查询朋友圈列表
                var momentList = await _momentDAL.GetMomentListAsync(currentUserId, pageIndex, pageSize);

                // 4. 返回结果
                return Ok(new
                {
                    code = 200,
                    message = "获取朋友圈列表成功",
                    data = new 
                    { 
                        moments = momentList,
                        pageIndex = pageIndex,
                        pageSize = pageSize,
                        totalCount = momentList.Count // 实际项目可新增查询总数的方法
                    }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "获取朋友圈列表失败");
                return StatusCode(500, new { code = 500, message = "服务器内部错误", data = "" });
            }
        }
    }
}