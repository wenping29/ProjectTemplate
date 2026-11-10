using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChatServer.Models.Entities
{
    /// <summary>
    /// 朋友圈实体类
    /// </summary>
    [Table("Moments")]
    public class Moment
    {
        /// <summary>
        /// 朋友圈ID
        /// </summary>
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        /// <summary>
        /// 发布者用户ID
        /// </summary>
        [Required]
        public int UserId { get; set; }

        /// <summary>
        /// 朋友圈内容
        /// </summary>
        [Required]
        [MaxLength(500)]
        public string Content { get; set; } = string.Empty;

        /// <summary>
        /// 图片列表（JSON格式存储，如 ["url1","url2"]）
        /// </summary>
        [MaxLength(1000)]
        public string Images { get; set; } = "[]";

        /// <summary>
        /// 发布时间
        /// </summary>
        [Required]
        public DateTime CreateTime { get; set; } = DateTime.Now;

        /// <summary>
        /// 点赞数
        /// </summary>
        public int LikeCount { get; set; } = 0;

        /// <summary>
        /// 评论数
        /// </summary>
        public int CommentCount { get; set; } = 0;

        /// <summary>
        /// 是否可见（0-仅自己，1-好友可见，2-公开）
        /// </summary>
        public int Visibility { get; set; } = 1;
    }
}