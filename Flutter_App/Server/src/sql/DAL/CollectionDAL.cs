using ChatServer.Data;
using ChatServer.Models;
using ChatServer.Utils;
using Microsoft.EntityFrameworkCore;

namespace ChatServer.DAL
{
    /// <summary>
    /// 收藏数据访问层
    /// </summary>
    public class CollectionDAL
    {
        private readonly AppDbContext _dbContext;
            private readonly JwtHelper _jwtHelper;

        public CollectionDAL(AppDbContext dbContext, JwtHelper jwtHelper)
        {
            _dbContext = dbContext;
            _jwtHelper = jwtHelper;
        }

        /// <summary>
        /// 根据用户ID查询收藏列表
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="pageIndex">页码（默认第1页）</param>
        /// <param name="pageSize">每页条数（默认10条）</param>
        /// <returns>收藏列表</returns>
        public async Task<List<Collection>> GetCollectionsByUserIdAsync(
            int userId, 
            int pageIndex = 1, 
            int pageSize = 10)
        {
            // 分页查询：按收藏时间倒序
            return await _dbContext.Collections
                .Where(c => c.UserId == userId)
                .OrderByDescending(c => c.CreateTime)
                .Skip((pageIndex - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();
        }

        /// <summary>
        /// 查询用户收藏总数
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>收藏总数</returns>
        public async Task<int> GetCollectionCountByUserIdAsync(int userId)
        {
            return await _dbContext.Collections
                .CountAsync(c => c.UserId == userId);
        }
    }
}