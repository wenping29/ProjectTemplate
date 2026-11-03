using System.ComponentModel.DataAnnotations.Schema;

namespace Server.Api.Models;

/// <summary>商品（示例业务表）</summary>
public class Product
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal Price { get; set; }
    public int Stock { get; set; }
    public short Status { get; set; } = 1;
    public Guid? CreatedBy { get; set; }

    [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
    public DateTime CreatedAt { get; set; }

    [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
    public DateTime UpdatedAt { get; set; }

    public DateTime? DeletedAt { get; set; }
}
