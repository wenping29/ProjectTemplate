using ChatServer.DAL;
using ChatServer.Models.DTOs;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace ChatServer.Controllers
{
    /// <summary>
    /// 收藏API控制器
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize] // 必须登录才能访问
    public class CollectionController : ControllerBase
    {
        private readonly CollectionDAL _collectionDAL;
        private readonly ILogger<CollectionController> _logger;

        public CollectionController(
            CollectionDAL collectionDAL,
            ILogger<CollectionController> logger)
        {
            _collectionDAL = collectionDAL;
            _logger = logger;
        }

        /// <summary>
        /// 查询当前用户的收藏列表（分页）
        /// </summary>
        /// <param name="pageIndex">页码（默认1）</param>
        /// <param name="pageSize">每页条数（默认10）</param>
        /// <returns>收藏列表</returns>
        [HttpGet("MyCollections")]
        public async Task<IActionResult> GetMyCollections(
            [FromQuery] int pageIndex = 1,
            [FromQuery] int pageSize = 10)
        {
            try
            {
                // 1. 从JWT令牌中获取当前用户ID
                var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userIdStr) || !int.TryParse(userIdStr, out int userId))
                {
                    _logger.LogWarning("获取用户ID失败：{userIdStr}", userIdStr);
                    return BadRequest(new { code = 400, message = "用户ID无效", data = "null" });
                }

                // 2. 校验分页参数
                if (pageIndex < 1) pageIndex = 1;
                if (pageSize < 1 || pageSize > 50) pageSize = 10;

                // 3. 查询收藏数据
                var collections = await _collectionDAL.GetCollectionsByUserIdAsync(userId, pageIndex, pageSize);
                var totalCount = await _collectionDAL.GetCollectionCountByUserIdAsync(userId);

                // 4. 转换为DTO（格式化时间）
                var collectionDTOs = collections.Select(c => new CollectionDTO
                {
                    Id = c.Id,
                    Title = c.Title,
                    Content = c.Content,
                    Type = c.Type,
                    CreateTime = c.CreateTime.ToString("yyyy-MM-dd HH:mm") // 格式化时间
                }).ToList();

                // 5. 构造返回结果
                var result = new CollectionListDTO
                {
                    Collections = collectionDTOs,
                    TotalCount = totalCount,
                    PageIndex = pageIndex,
                    PageSize = pageSize
                };

                return Ok(new { code = 200, message = "查询成功", data = result });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "查询收藏失败");
                return StatusCode(500, new { code = 500, message = "服务器内部错误", data = "null" });
            }
        }
    }
}