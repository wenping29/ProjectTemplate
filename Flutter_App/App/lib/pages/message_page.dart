import 'package:flutter/material.dart';
import 'chat_window_page.dart';
import '../utils/network_utils.dart';
import 'login_page.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;
  String _errorMsg = '';

  // 🔴 核心修复：安全加载会话列表（包含异常捕获+数据校验）
  Future<void> _loadSessions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMsg = '';
      });
      print("调用服务端接口");
      // 调用服务端接口
      final response = await NetworkUtils.get('Chat/Sessions');
      // 1. 处理服务端返回码
      if (response['code'] != 200) {
        final String msg = response['message'] ?? '加载会话失败';
        // 401未授权：跳转到登录页
        if (response['code'] == 401) {
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            });
          }
          return;
        }
        setState(() => _errorMsg = msg);
        return;
      }

      // 2. 校验返回数据格式
      final dynamic data = response['data'];
      if (data == null || data is! List) {
        setState(() => _errorMsg = '服务端返回数据格式错误');
        return;
      }

      // 3. 安全解析数据（处理空值+类型转换）
      final List<Map<String, dynamic>> sessions = [];
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          // 安全获取字段，设置默认值
          final Map<String, dynamic> session = {
            'sessionId': item['sessionId'] ?? item['SessionId'] ?? '', // 兼容大小写
            'sessionName': item['sessionName'] ?? item['SessionName'] ?? '未知会话',
            'lastMessage': item['lastMessage'] ?? item['LastMessage'] ?? '',
            'lastMessageTime':
                item['lastMessageTime'] ?? item['LastMessageTime'] ?? '',
            'unreadCount':
                int.tryParse(
                  '${item['unreadCount'] ?? item['UnreadCount'] ?? 0}',
                ) ??
                0,
            'isGroup': item['isGroup'] ?? item['IsGroup'] ?? false,
            'userId1': item['userId1'] ?? item['UserId1'] ?? 0,
            'userId2': item['userId2'] ?? item['UserId2'] ?? 0,
          };
          // 过滤无效会话
          if (session['sessionId'].isNotEmpty) {
            sessions.add(session);
          }
        }
      }

      // 4. 更新UI
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      // 捕获所有异常（网络/解析/其他）
      //debugPrint('加载会话异常：$e\n$stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMsg = '网络异常：${e.toString().substring(0, 50)}'; // 缩短错误信息
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // 延迟加载，避免页面初始化冲突
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('搜索消息'))),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('新建聊天'))),
          ),
        ],
      ),
      body: _buildBody(),
      // 🔴 新增：下拉刷新
      floatingActionButton: _errorMsg.isNotEmpty
          ? FloatingActionButton.small(
              onPressed: _loadSessions,
              child: const Icon(Icons.refresh),
            )
          : null,
    );
  }

  // 🔴 修复UI渲染逻辑（处理所有边界状态）
  Widget _buildBody() {
    // 加载中状态
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载会话中...'),
          ],
        ),
      );
    }

    // 错误状态
    if (_errorMsg.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMsg,
                style: const TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadSessions,
                child: const Text('重新加载'),
              ),
            ],
          ),
        ),
      );
    }

    // 空数据状态
    if (_sessions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无聊天会话', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    // 正常渲染会话列表
    return RefreshIndicator(
      onRefresh: _loadSessions, // 下拉刷新
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _sessions.length,
        itemBuilder: (context, index) {
          final session = _sessions[index];
          // 🔴 安全获取所有字段，避免空指针
          final String sessionId = session['sessionId'] ?? '';
          final String sessionName = session['sessionName'] ?? '未知会话';
          final String lastMessage = session['lastMessage'] ?? '暂无消息';
          final String lastMessageTime = session['lastMessageTime'] ?? '';
          final int unreadCount = session['unreadCount'] ?? 0;
          final bool isGroup = session['isGroup'] ?? false;
          final int userId1 = session['userId1'] ?? 0;
          final int userId2 = session['userId2'] ?? 0;

          // 获取好友ID（不是当前用户的那个ID）
          // 临时假设当前用户ID为1
          final int currentUserId = 1;
          final int friendId = userId1 == currentUserId ? userId2 : userId1;

          return InkWell(
            onTap: () {
              // 🔴 安全跳转：会话ID为空时不跳转
              if (sessionId.isEmpty) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatWindowPage(
                    sessionId: sessionId,
                    friendId: friendId,
                    friendName: sessionName,
                    friendAvatar: isGroup
                        ? "assets/images/avatar.png"
                        : "assets/images/avatar.png",
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  // bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  // 头像
                  CircleAvatar(
                    child: Icon(isGroup ? Icons.group : Icons.person),
                    radius: 24,
                  ),
                  const SizedBox(width: 12),

                  // 会话内容
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              sessionName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _formatTime(lastMessageTime),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lastMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),

                  // 未读消息数（安全渲染）
                  if (unreadCount > 0 && unreadCount < 99)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (unreadCount >= 99)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '99+',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔴 修复时间格式化（处理空值+异常）
  String _formatTime(String timeStr) {
    // 空值直接返回空
    if (timeStr.isEmpty || timeStr == 'null') return '';

    try {
      final DateTime time = DateTime.parse(timeStr);
      final now = DateTime.now();

      // 今天：显示时分
      if (time.year == now.year &&
          time.month == now.month &&
          time.day == now.day) {
        return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
      }
      // 今年：显示月日
      else if (time.year == now.year) {
        return '${time.month}-${time.day}';
      }
      // 往年：显示年月日
      else {
        return '${time.year}-${time.month}-${time.day}';
      }
    } catch (e) {
      // 解析失败返回原字符串（截断）
      return timeStr.length > 10 ? timeStr.substring(0, 10) : timeStr;
    }
  }
}
