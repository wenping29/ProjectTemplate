import 'package:flutter/material.dart';
import 'message_page.dart';
import 'friend_page.dart';
import 'moments_page.dart';
import 'mine_page.dart';
import 'login_page.dart';
import 'map_page.dart';
import '../utils/network_utils.dart';

class MainNavPage extends StatefulWidget {
  const MainNavPage({super.key});

  @override
  State<MainNavPage> createState() => _MainNavPageState();
}

class _MainNavPageState extends State<MainNavPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    MessagePage(),
    FriendPage(),
    MomentPage(),
    AddMapPage(),
    MinePage(),
  ];

  @override
  void initState() {
    super.initState();

    // 路由守卫：检查令牌是否存在
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isLoggedIn()) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.message), label: '消息'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '好友'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_album), label: '朋友圈'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_album), label: '地图'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
