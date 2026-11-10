namespace ChatServer.Models.DTOs
{
    /// <summary>
    /// 好友列表DTO
    /// </summary>
    public class FriendListItemDTO
    {
        /// <summary>
        /// 好友ID
        /// </summary>
        public int FriendId { get; set; }

        /// <summary>
        /// 好友用户名
        /// </summary>
        public string Username { get; set; } = string.Empty;

        /// <summary>
        /// 好友头像
        /// </summary>
        public string Avatar { get; set; } = string.Empty;

        /// <summary>
        /// 备注名
        /// </summary>
        public string RemarkName { get; set; } = string.Empty;

        /// <summary>
        /// 添加时间
        /// </summary>
        public string AddTime { get; set; } = string.Empty;

        /// <summary>
        /// 好友手机号
        /// </summary>
        public string Phone { get; set; } = string.Empty;
    }
}