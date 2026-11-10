import 'package:flutter/material.dart';
import 'chat_window_page.dart';

class FriendInfoPage extends StatefulWidget {
  final int friendId;
  final String username;
  final String avatar;
  final String remarkName;
  final String phone;

  const FriendInfoPage({
    super.key,
    required this.friendId,
    required this.username,
    required this.avatar,
    required this.remarkName,
    required this.phone,
  });

  @override
  State<FriendInfoPage> createState() => _FriendInfoPage();
}

class _FriendInfoPage extends State<FriendInfoPage> {
  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('弹窗标题'),
        content: const Text("networkType"),
        actions: [
          TextButton(
            child: const Text('取消'),
            onPressed: () => {
              // 跳转到聊天页面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => ChatWindowPage(
                    friendId: widget.friendId,
                    friendName: "showName",
                    friendAvatar: widget.avatar,
                  ),
                ),
              ),
            },
          ),
          TextButton(
            child: const Text('确定'),
            onPressed: () => {
              // 跳转到聊天页面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => ChatWindowPage(
                    friendId: widget.friendId,
                    friendName: "showName",
                    friendAvatar: widget.avatar,
                  ),
                ),
              ),
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String showName = "sadasdasdadd";

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage(
                'assets/avatar_default.png',
              ), // 替换为你的默认头像路径
            ),
            const SizedBox(width: 8),
            Text("好友资料"),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('查看${widget.username}的聊天信息')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 头像
            CircleAvatar(
              radius: 50,
              backgroundImage: widget.avatar.startsWith("http")
                  ? NetworkImage(widget.avatar)
                  : AssetImage(widget.avatar) as ImageProvider,
            ),
            SizedBox(height: 20),

            // 昵称/备注
            Text(
              showName,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // 账号
            Text("账号：$widget.username"),
            SizedBox(height: 8),
            Text("手机号：$widget.phone"),
            SizedBox(height: 30),

            // 发消息按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 跳转到聊天页面
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => ChatWindowPage(
                        friendId: widget.friendId,
                        friendName: showName,
                        friendAvatar: widget.avatar,
                      ),
                    ),
                  );
                },
                child: Text("发消息"),
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 跳转到聊天页面
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => ChatWindowPage(
                        friendId: widget.friendId,
                        friendName: showName,
                        friendAvatar: widget.avatar,
                      ),
                    ),
                  );
                },
                child: Text("朋友圈"),
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showDialog();
                },
                child: Text("视频"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
