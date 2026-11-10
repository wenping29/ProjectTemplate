using ChatServer.Data;
using ChatServer.DTOs;
using ChatServer.Models;
using Microsoft.EntityFrameworkCore;

namespace ChatServer.Services;

public class ChatService
{
    private readonly AppDbContext _dbContext;

    public ChatService(AppDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    // 获取用户的聊天会话列表
    public async Task<ResponseDto<List<ChatSession>>> GetSessions(int userId)
    {
        var sessions = await _dbContext.ChatSessions
            .Where(s => s.UserId1 == userId || s.UserId2 == userId)
            .OrderByDescending(s => s.LastMessageTime)
            .ToListAsync() ;
        if (sessions.Count > 0)
        {
            return ResponseDto<List<ChatSession>>.Success(sessions);
        }
        else
        {
            return ResponseDto<List<ChatSession>>.Success(new List<ChatSession>() { });
        }
    }

    // 获取会话的聊天记录
    public async Task<ResponseDto<List<ChatMessage>>> GetMessages(string sessionId)
    {
        var messages = await _dbContext.ChatMessages
            .Where(m => m.SessionId == sessionId)
            .OrderBy(m => m.SendTime)
            .ToListAsync();
        
        // 标记消息为已读
        var unreadMessages = messages.Where(m => !m.IsRead).ToList();
        foreach (var msg in unreadMessages)
        {
            msg.IsRead = true;
        }
        await _dbContext.SaveChangesAsync();

        return ResponseDto<List<ChatMessage>>.Success(messages);
    }

    // 发送消息
    public async Task<ResponseDto<ChatMessage>> SendMessage(int senderId, SendMessageRequest request)
    {
        // 创建消息
        var message = new ChatMessage
        {
            SessionId = request.SessionId,
            SenderId = senderId,
            Content = request.Content,
            SendTime = DateTime.Now,
            IsRead = false
        };

        _dbContext.ChatMessages.Add(message);

        // 更新会话最后消息
        var session = await _dbContext.ChatSessions.FirstOrDefaultAsync(s => s.SessionId == request.SessionId);
        if (session != null)
        {
            session.LastMessage = request.Content;
            session.LastMessageTime = DateTime.Now;
            session.UnreadCount += 1;
        }

        await _dbContext.SaveChangesAsync();
        return ResponseDto<ChatMessage>.Success(message, "消息发送成功");
    }
}