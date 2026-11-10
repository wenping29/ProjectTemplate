using ChatServer.DAL;
using ChatServer.DTOs;
using ChatServer.Models;
using ChatServer.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace ChatServer.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize] // 需要JWT认证
public class UserController : ControllerBase
{
    private readonly Data.AppDbContext _dbContext;
    private readonly ILogger<UserController> _logger;
    private readonly UserDAL _userDAL;

    public UserController(Data.AppDbContext dbContext,  UserDAL userDAL,
            ILogger<UserController> logger)
    {
        _dbContext = dbContext;
          _userDAL = userDAL;
            _logger = logger;
    }

    /// <summary>
    /// 获取当前登录用户信息
    /// </summary>
    /// <returns>用户信息</returns>
    [HttpGet("Profile")]
    [HttpPost("Profile")]
    public async Task<ActionResult<ResponseDto<User>>> GetUserProfile()
    {
        // 从JWT令牌获取当前用户ID
        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        
        var user = await _dbContext.Users
            .Select(u => new User
            {
                Id = u.Id,
                Username = u.Username,
                Email = u.Email,
                Avatar = u.Avatar,
                CreateTime = u.CreateTime,
                LastLoginTime = u.LastLoginTime
            }) // 排除密码字段
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user == null)
        {
            return Ok(ResponseDto<User>.Fail("用户不存在", 404));
        }

        return Ok(ResponseDto<User>.Success(user));
    }

    /// <summary>
    /// 修改用户密码
    /// </summary>
    /// <param name="request">密码修改请求</param>
    /// <returns>操作结果</returns>
    [HttpPost("ChangePassword")]
    public async Task<ActionResult<ResponseDto>> ChangePassword([FromBody] ChangePasswordRequest request)
    {
        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == userId);

        if (user == null)
        {
            return Ok(ResponseDto.Fail("用户不存在", 404));
        }

        // 验证原密码
        if (user.Password != MD5Helper.MD5Encrypt(request.OldPassword))
        {
            return Ok(ResponseDto.Fail("原密码错误", 400));
        }

        // 修改密码
        user.Password = MD5Helper.MD5Encrypt(request.NewPassword);
        await _dbContext.SaveChangesAsync();

        return Ok(ResponseDto.Success("密码修改成功"));
    }

    /// <summary>
    /// 更新用户头像
    /// </summary>
    /// <param name="avatarUrl">头像URL</param>
    /// <returns>操作结果</returns>
    [HttpPost("UpdateAvatar")]
    public async Task<ActionResult<ResponseDto>> UpdateAvatar([FromBody] string avatarUrl)
    {
        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == userId);

        if (user == null)
        {
            return Ok(ResponseDto.Fail("用户不存在", 404));
        }

        user.Avatar = avatarUrl;
        await _dbContext.SaveChangesAsync();

        return Ok(ResponseDto.Success("头像更新成功"));
    }

    /// <summary>
    /// 获取当前登录用户的信息
    /// </summary>
    /// <returns>用户基础信息</returns>
    [HttpGet("MyInfo")]
    public async Task<IActionResult> GetMyInfo()
        {
            try
            {
                // 1. 从JWT令牌解析当前用户ID
                var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userIdStr) || !int.TryParse(userIdStr, out int userId))
                {
                    _logger.LogWarning("解析用户ID失败：{userIdStr}", userIdStr);
                    return BadRequest(new { code = 400, message = "用户ID无效", data = "" });
                }

                // 2. 查询用户信息
                var userInfo = await _userDAL.GetUserInfoByIdAsync(userId);
                if (userInfo == null)
                {
                    return NotFound(new { code = 404, message = "用户信息不存在", data = "" });
                }

                // 3. 构造返回数据（隐藏敏感字段，仅返回前端需要的信息）
                var result = new
                {
                    Id = userInfo.Id,
                    Username = userInfo.Username,
                    Avatar = userInfo.Avatar,
                    Phone = userInfo.Phone,
                    Email = userInfo.Email,
                    Gender = "",//userInfo.Gender,
                    RegisterTime = userInfo.LastLoginTime,
                    LastLoginTime = userInfo.LastLoginTime
                };

                // 4. 返回结果
                return Ok(new
                {
                    code = 200,
                    message = "获取用户信息成功",
                    data = result
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "获取用户信息失败");
                return StatusCode(500, new { code = 500, message = "服务器内部错误", data = "" });
            }
        }
}

/// <summary>
/// 密码修改请求DTO
/// </summary>
public class ChangePasswordRequest
{
    /// <summary>
    /// 原密码
    /// </summary>
    public string OldPassword { get; set; } = string.Empty;

    /// <summary>
    /// 新密码
    /// </summary>
    public string NewPassword { get; set; } = string.Empty;
}

 
   

        
