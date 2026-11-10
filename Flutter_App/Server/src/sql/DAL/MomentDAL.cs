using ChatServer.Data;
using ChatServer.Models.Entities;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace ChatServer.DAL
{
    /// <summary>
    /// 朋友圈数据访问层
    /// </summary>
    public class MomentDAL
    {
        private readonly AppDbContext _dbContext;

        public MomentDAL(AppDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        /// <summary>
        /// 获取当前用户可见的朋友圈列表（分页）
        /// </summary>
        /// <param name="currentUserId">当前登录用户ID</param>
        /// <param name="pageIndex">页码</param>
        /// <param name="pageSize">每页条数</param>
        /// <returns>朋友圈列表（包含发布者信息）</returns>
        public async Task<List<dynamic>> GetMomentListAsync(
            int currentUserId, 
            int pageIndex = 1, 
            int pageSize = 10)
        {
            // 1. 获取当前用户的好友ID列表（用于筛选好友可见的朋友圈）
            var friendIds = await _dbContext.Friends
                .Where(f => f.UserId == currentUserId && f.Status == 1)
                .Select(f => f.FriendUserId)
                .ToListAsync();
            // 包含自己的ID（能看自己的朋友圈）
            friendIds.Add(currentUserId);

            // 2. 分页查询朋友圈（按发布时间倒序）
            var momentList = await _dbContext.Moments
                .Where(m => 
                    // 公开的朋友圈 + 好友可见且发布者是好友/自己 + 仅自己可见且是自己发布
                    (m.Visibility == 2) || 
                    (m.Visibility == 1 && friendIds.Contains(m.UserId)) || 
                    (m.Visibility == 0 && m.UserId == currentUserId)
                )
                .Join(
                    _dbContext.Users, // 关联用户表获取发布者信息
                    m => m.UserId,
                    u => u.Id,
                    (m, u) => new
                    {
                        MomentId = m.Id,
                        UserId = m.UserId,
                        Username = u.Username,
                        Avatar = u.Avatar ?? "/assets/avatar_default.png",
                        Content = m.Content,
                        // 解析图片JSON为列表
                        Images = new List<String>{},//JsonSerializer.Deserialize<List<string>>(m.Images) ?? new List<string>(),
                        CreateTime = "eqweeqwew",//m.CreateTime.ToString("yyyy-MM-dd HH:mm"),
                        LikeCount = m.LikeCount,
                        CommentCount = m.CommentCount
                    }
                )
                .OrderByDescending(m => m.CreateTime)
                .Skip((pageIndex - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            // 转换为dynamic便于JSON序列化
            return momentList.Select(m => new
            {
                m.MomentId,
                m.UserId,
                m.Username,
                m.Avatar,
                m.Content,
                m.Images,
                m.CreateTime,
                m.LikeCount,
                m.CommentCount
            }).Cast<dynamic>().ToList();
        }
    }
}