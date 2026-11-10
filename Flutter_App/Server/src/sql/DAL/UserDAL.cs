using ChatServer.Data;
using ChatServer.Models;
using ChatServer.Models.Entities;
using Microsoft.EntityFrameworkCore;

namespace ChatServer.DAL
{
    /// <summary>
    /// 用户数据访问层
    /// </summary>
    public class UserDAL
    {
        private readonly AppDbContext _dbContext;

        public UserDAL(AppDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        /// <summary>
        /// 根据用户ID查询用户基础信息
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>用户信息</returns>
        public async Task<User?> GetUserInfoByIdAsync(int userId)
        {
            return await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == userId) as User;
        }
    }
}