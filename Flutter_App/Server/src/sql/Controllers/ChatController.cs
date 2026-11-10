using ChatServer.DTOs;
using ChatServer.Models;
using ChatServer.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace ChatServer.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize] // 需要JWT认证
public class ChatController : ControllerBase
{
    private readonly ChatService _chatService;

    public ChatController(ChatService chatService)
    {
        _chatService = chatService;
    }

    // 获取当前用户的会话列表 GET /api/Chat/Sessions
    [HttpGet("Sessions")]
    [HttpPost("Sessions")]
    
    public async Task<ActionResult<ResponseDto<List<ChatSession>>>> GetSessions()
    {
        // 从JWT获取当前用户ID
        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _chatService.GetSessions(userId);
        return Ok(result);
    }

    // 获取会话消息 GET /api/Chat/Messages/{sessionId}
    [HttpGet("Messages/{sessionId}")]
    public async Task<ActionResult<ResponseDto<List<ChatMessage>>>> GetMessages(string sessionId)
    {
        var result = await _chatService.GetMessages(sessionId);
        return Ok(result);
    }

    // 发送消息 POST /api/Chat/SendMessage
    [HttpPost("SendMessage")]
    public async Task<ActionResult<ResponseDto<ChatMessage>>> SendMessage([FromBody] SendMessageRequest request)
    {
        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _chatService.SendMessage(userId, request);
        return Ok(result);
    }
}