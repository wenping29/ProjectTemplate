using ChatServer.DAL;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace ChatServer.Controllers
{
    /// <summary>
    /// 好友API控制器
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize] // 需登录才能访问
    public class FriendController : ControllerBase
    {
        private readonly FriendDAL _friendDAL;
        private readonly ILogger<FriendController> _logger;

        public FriendController(
            FriendDAL friendDAL,
            ILogger<FriendController> logger)
        {
            _friendDAL = friendDAL;
            _logger = logger;
        }

        /// <summary>
        /// 查询当前用户的好友列表
        /// </summary>
        /// <returns>好友列表</returns>
        [HttpGet("MyFriends")]
        public async Task<IActionResult> GetMyFriends()
        {
            try
            {
                // 1. 从JWT令牌解析当前用户ID
                var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userIdStr) || !int.TryParse(userIdStr, out int userId))
                {
                    _logger.LogWarning("解析用户ID失败：{userIdStr}", userIdStr);
                    return BadRequest(new { code = 400, message = "用户ID无效", data =  "" });
                }

                // 2. 查询好友列表
                var friendList = await _friendDAL.GetFriendListAsync(userId);

                // 3. 返回结果
                return Ok(new
                {
                    code = 200,
                    message = "查询好友列表成功",
                    data = new { friends = friendList }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "查询好友列表失败");
                return StatusCode(500, new { code = 500, message = "服务器内部错误", data = "" });
            }
        }
    }
}