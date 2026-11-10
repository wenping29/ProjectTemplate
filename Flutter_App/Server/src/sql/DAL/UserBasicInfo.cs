using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChatServer.Models.Entities
{
    /// <summary>
    /// 用户基础信息实体
    /// </summary>
    [Table("Users")]
    public class UserBasicInfo
    {
        /// <summary>
        /// 用户ID
        /// </summary>
        [Key]
        public int Id { get; set; }

        /// <summary>
        /// 用户名
        /// </summary>
        [Required]
        [MaxLength(50)]
        public string Username { get; set; } = string.Empty;

        /// <summary>
        /// 头像地址
        /// </summary>
        [MaxLength(200)]
        public string Avatar { get; set; } = "/assets/avatar_default.png";

        /// <summary>
        /// 手机号
        /// </summary>
        [MaxLength(20)]
        public string Phone { get; set; } = string.Empty;

        /// <summary>
        /// 邮箱
        /// </summary>
        [MaxLength(100)]
        public string Email { get; set; } = string.Empty;

        /// <summary>
        /// 性别（0-未知，1-男，2-女）
        /// </summary>
        public int Gender { get; set; } = 0;

        /// <summary>
        /// 注册时间
        /// </summary>
        public DateTime RegisterTime { get; set; } = DateTime.Now;

        /// <summary>
        /// 最后登录时间
        /// </summary>
        public DateTime LastLoginTime { get; set; } = DateTime.Now;
    }
}