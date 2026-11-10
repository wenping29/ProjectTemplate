import 'package:flutter/material.dart';
import '../utils/network_utils.dart';
import '../utils/list_utils.dart';
import 'friend_info_page.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  // 好友列表（强类型）
  List<Map<String, dynamic>> _friendList = [];
  bool _isLoading = true;
  String _errorMsg = '';

  // 加载好友列表
  Future<void> _loadFriendList() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });
    //http://localhost:58558/assets//assets/avatar_default.png
    try {
      final response = await NetworkServices.getMyFriends();
      if (response['code'] == 200) {
        // 安全转换List类型（核心修复类型错误）
        List<dynamic> rawList = response['data']?['friends'] ?? [];
        setState(() {
          _friendList = ListUtils.toMapList(rawList);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMsg = response['message'] ?? '查询好友列表失败';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = '网络异常：$e';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // 页面初始化加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFriendList();
    });
  }

  // 构建好友列表项
  Widget _buildFriendItem(Map<String, dynamic> friend) {
    // 安全取值
    String username = friend['username']?.toString() ?? '未知好友';
    String avatar = friend['avatar']?.toString() ?? 'assets/avatar_default.png';
    String remarkName = friend['remarkName']?.toString() ?? '';
    String addTime = friend['addTime']?.toString() ?? '';
    int friendId = friend['friendId'];

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(avatar),
        // 网络图片替换：NetworkImage(avatar)
      ),
      title: Text(remarkName.isNotEmpty ? remarkName : username),
      subtitle: Text('添加时间：$addTime'),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: Colors.grey,
      ),
      onTap: () {
        // 跳转到好友详情页
        //if (sessionId.isEmpty) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FriendInfoPage(
              friendId: friendId,
              username: username,
              avatar: avatar,
              remarkName: remarkName,
              phone: MapUtils.getString(friend, "Phone", defaultValue: "未知"),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的好友'), elevation: 1),
      body: _isLoading
          ? // 加载中
            const Center(child: CircularProgressIndicator())
          : _errorMsg.isNotEmpty
          ? // 加载失败
            Center(
              child: Text(_errorMsg, style: const TextStyle(color: Colors.red)),
            )
          : _friendList.isEmpty
          ? // 无数据
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('暂无好友，快去添加吧～', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : // 好友列表
            ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: _friendList.length,
              itemBuilder: (context, index) {
                return _buildFriendItem(_friendList[index]);
              },
              separatorBuilder: (context, index) {
                return const Divider(height: 1);
              },
            ),
    );
  }
}
