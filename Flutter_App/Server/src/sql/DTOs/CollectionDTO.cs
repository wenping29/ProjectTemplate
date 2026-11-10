namespace ChatServer.Models.DTOs
{
    /// <summary>
    /// 收藏DTO（API返回用）
    /// </summary>
    public class CollectionDTO
    {
        /// <summary>
        /// 收藏ID
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// 收藏标题
        /// </summary>
        public string Title { get; set; } = string.Empty;

        /// <summary>
        /// 收藏内容/链接
        /// </summary>
        public string Content { get; set; } = string.Empty;

        /// <summary>
        /// 收藏类型
        /// </summary>
        public string Type { get; set; } = "default";

        /// <summary>
        /// 收藏时间（格式化）
        /// </summary>
        public string CreateTime { get; set; } = string.Empty;
    }

    /// <summary>
    /// 收藏查询结果DTO
    /// </summary>
    public class CollectionListDTO
    {
        /// <summary>
        /// 收藏列表
        /// </summary>
        public List<CollectionDTO> Collections { get; set; } = new List<CollectionDTO>();

        /// <summary>
        /// 总数
        /// </summary>
        public int TotalCount { get; set; }

        /// <summary>
        /// 页码
        /// </summary>
        public int PageIndex { get; set; }

        /// <summary>
        /// 每页条数
        /// </summary>
        public int PageSize { get; set; }
    }
}