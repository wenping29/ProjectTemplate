using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChatServer.Models
{
    /// <summary>
    /// 收藏实体类
    /// </summary>
    [Table("Collections")]
    public class Collection
    {
        /// <summary>
        /// 收藏ID
        /// </summary>
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        /// <summary>
        /// 用户ID（关联用户表）
        /// </summary>
        [Required]
        public int UserId { get; set; }

        /// <summary>
        /// 收藏标题
        /// </summary>
        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;

        /// <summary>
        /// 收藏内容/链接
        /// </summary>
        [MaxLength(500)]
        public string Content { get; set; } = string.Empty;

        /// <summary>
        /// 收藏类型（如：消息、文章、链接等）
        /// </summary>
        [MaxLength(50)]
        public string Type { get; set; } = "default";

        /// <summary>
        /// 收藏时间
        /// </summary>
        [Required]
        public DateTime CreateTime { get; set; } = DateTime.Now;
    }
}