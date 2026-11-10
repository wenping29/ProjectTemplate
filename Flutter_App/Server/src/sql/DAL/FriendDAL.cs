using ChatServer.Data;
using Microsoft.EntityFrameworkCore;

namespace ChatServer.DAL
{
    /// <summary>
    /// 好友数据访问层
    /// </summary>
    public class FriendDAL
    {
        private readonly AppDbContext _dbContext;

        public FriendDAL(AppDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        /// <summary>
        /// 查询当前用户的好友列表（已通过）
        /// </summary>
        /// <param name="userId">当前用户ID</param>
        /// <returns>好友列表（包含用户基础信息）</returns>
        public async Task<List<dynamic>> GetFriendListAsync(int userId)
        {
            // 查询当前用户的好友关系
            var friendRelations = await _dbContext.Friends
                .Where(f => f.UserId == userId && f.Status == 1)
                .ToListAsync();

            // 获取所有好友的用户ID
            var friendUserIds = friendRelations.Select(f => f.FriendUserId).ToList();

            // 查询这些用户的详细信息
            var users = await _dbContext.Users
                .Where(u => friendUserIds.Contains(u.Id))
                .ToDictionaryAsync(u => u.Id);

            // 组装结果
            var result = friendRelations.Select(f =>
            {
                var friendUser = users.TryGetValue(f.FriendUserId, out var user) ? user : null;
                return new
                {
                    FriendId = f.FriendUserId,
                    Username = friendUser?.Username ?? "未知用户",
                    Avatar = friendUser?.Avatar ?? "/assets/avatar_default.png",
                    RemarkName = f.RemarkName,
                    AddTime = f.CreateTime.ToString("yyyy-MM-dd"),
                    Phone = friendUser?.Phone ?? "未知",
                };
            }).OrderByDescending(x => x.AddTime).Cast<dynamic>().ToList();

            return result;
        }
    }
}
