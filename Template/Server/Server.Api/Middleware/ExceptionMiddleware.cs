using System.Net;
using System.Text.Json;
using Server.Api.Common;

namespace Server.Api.Middleware;

/// <summary>统一异常拦截：返回 { code:500, message, data:null }</summary>
public class ExceptionMiddleware
{
    private readonly RequestDelegate _next;
    public ExceptionMiddleware(RequestDelegate next) => _next = next;

    public async Task InvokeAsync(HttpContext ctx)
    {
        try
        {
            await _next(ctx);
        }
        catch (InvalidOperationException ex)
        {
            ctx.Response.StatusCode = (int)HttpStatusCode.BadRequest;
            await WriteAsync(ctx, ApiResult.Fail(400, ex.Message));
        }
        catch (Exception ex)
        {
            ctx.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
            await WriteAsync(ctx, ApiResult.Fail(500, ex.Message));
        }
    }

    private static async Task WriteAsync(HttpContext ctx, ApiResult result)
    {
        ctx.Response.ContentType = "application/json; charset=utf-8";
        await ctx.Response.WriteAsync(JsonSerializer.Serialize(result));
    }
}
