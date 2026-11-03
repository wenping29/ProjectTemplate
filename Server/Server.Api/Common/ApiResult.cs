namespace Server.Api.Common;

/// <summary>统一 API 响应结构：{ code, message, data }</summary>
public record ApiResult(int Code, string Message, object? Data)
{
    public static ApiResult Ok(object? data = null) => new(0, "ok", data);
    public static ApiResult Fail(int code, string message) => new(code, message, null);
}

/// <summary>登录返回</summary>
public record AuthResult(string AccessToken, Guid UserId, string Username, string? DisplayName, Guid RoleId);
