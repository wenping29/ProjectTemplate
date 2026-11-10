using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChatServer.Models
{
    /// <summary>
    /// 好友关系实体类
    /// </summary>
    [Table("Friends")]
    public class Friend
    {
        /// <summary>
        /// 主键ID
        /// </summary>
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        /// <summary>
        /// 当前用户ID（谁的好友列表）
        /// </summary>
        [Required]
        public int UserId { get; set; }

        /// <summary>
        /// 好友用户ID
        /// </summary>
        [Required]
        public int FriendUserId { get; set; }

        /// <summary>
        /// 好友备注名
        /// </summary>
        [MaxLength(50)]
        public string RemarkName { get; set; } = string.Empty;

        /// <summary>
        /// 好友状态（0-待验证，1-已通过，2-已拉黑）
        /// </summary>
        [Required]
        public int Status { get; set; } = 1;

        /// <summary>
        /// 添加时间
        /// </summary>
        [Required]
        public DateTime CreateTime { get; set; } = DateTime.Now;
    }

    /// <summary>
    /// 用户基础信息实体（用于返回好友信息）
    /// </summary>
    public class UserBasicInfo
    {
        public int Id { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Avatar { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
    }
}