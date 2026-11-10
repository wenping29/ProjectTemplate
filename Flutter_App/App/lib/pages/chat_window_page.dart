import 'package:flutter/material.dart';
import '../utils/network_utils.dart';

class ChatWindowPage extends StatefulWidget {
  final String? sessionId;
  final int friendId;
  final String friendName;
  final String friendAvatar;

  const ChatWindowPage({
    super.key,
    this.sessionId,
    required this.friendId,
    required this.friendName,
    required this.friendAvatar,
  });

  @override
  State<ChatWindowPage> createState() => _ChatWindowPageState();
}

class _ChatWindowPageState extends State<ChatWindowPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _chatRecords = [];
  bool _isLoading = true;
  bool _isSending = false;

  // 加载聊天记录
  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    // 生成sessionId（如果没有提供的话）
    // 临时假设当前用户ID为1
    final int currentUserId = 1;
    final String sessionId =
        widget.sessionId ?? _generateSessionId(currentUserId, widget.friendId);

    final response = await NetworkUtils.get('Chat/Messages/$sessionId');
    setState(() => _isLoading = false);

    if (mounted) {
      if (response['code'] == 200) {
        setState(() {
          _chatRecords = List<Map<String, dynamic>>.from(response['data']);
        });
        // 在下一帧中滚动到底部，确保ListView已渲染完成
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载消息失败：${response['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 生成sessionId
  String _generateSessionId(int userId1, int userId2) {
    final List<int> ids = [userId1, userId2]..sort();
    return 'user_${ids[0]}_user_${ids[1]}';
  }

  // 发送消息到服务端
  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    // 生成sessionId（如果没有提供的话）
    // 临时假设当前用户ID为1
    final int currentUserId = 1;
    final String sessionId =
        widget.sessionId ?? _generateSessionId(currentUserId, widget.friendId);

    // 构建请求参数
    final requestData = {'SessionId': sessionId, 'Content': content};

    // 调用发送消息API
    final response = await NetworkUtils.post(
      'Chat/SendMessage',
      data: requestData,
    );
    setState(() => _isSending = false);

    if (mounted) {
      if (response['code'] == 200) {
        // 发送成功：添加新消息并清空输入框
        setState(() {
          _chatRecords.add(response['data']);
          _messageController.clear();
        });
        // 在下一帧中滚动到底部，确保新消息已渲染
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发送失败：${response['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 滚动到底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // 添加一个短暂延迟，确保内容已经完全渲染
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            //AssetImage(avatar)
            // CircleAvatar(child: Icon(Icons.arrow_forward_ios)),
            const CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage(
                'assets/avatar_default.png',
              ), // 替换为你的默认头像路径
            ),
            const SizedBox(width: 8),
            Text(widget.friendName),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('拨打${widget.friendName}的电话')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('查看${widget.friendName}的聊天信息')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 聊天记录
          Expanded(child: _buildMessageList()),

          // 输入框区域
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                // 表情按钮
                IconButton(
                  icon: const Icon(Icons.emoji_emotions, color: Colors.grey),
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('表情面板待开发')));
                  },
                ),

                // 附件按钮
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.grey),
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('文件/图片上传待开发')));
                  },
                ),

                // 输入框
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '输入消息...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      filled: true,
                      // fillColor: Colors.grey[100],
                      // borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    maxLines: 4,
                    minLines: 1,
                  ),
                ),

                // 发送按钮
                IconButton(
                  icon: _isSending
                      ? const CircularProgressIndicator(
                          color: Colors.blue,
                          strokeWidth: 2,
                        )
                      : const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建消息列表（处理加载状态）
  Widget _buildMessageList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_chatRecords.isEmpty) {
      return const Center(child: Text('暂无聊天记录'));
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: false,
      padding: const EdgeInsets.all(12),
      itemCount: _chatRecords.length,
      itemBuilder: (context, index) {
        final record = _chatRecords[index];
        // 从JWT解析当前用户ID（简化处理，实际需存储用户信息）
        // 这里临时假设当前用户ID为1，需替换为真实用户ID
        final int currentUserId = 1;
        final bool isMe = record['senderId'] == currentUserId;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    record['content'],
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(record['sendTime']),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 格式化时间
  String _formatTime(String timeStr) {
    try {
      final DateTime time = DateTime.parse(timeStr);
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timeStr;
    }
  }
}
