import 'package:flutter/material.dart';
import 'models/menu_item.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';

/// 主框架：包含可配置的底部菜单（底部菜单配置）。
/// 实际项目可在 initState 中请求 `GET /api/menus/tree`，由服务端决定展示哪些 Tab。
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;

  // 默认底部菜单（可由服务端下发覆盖）
  final List<MenuItem> _tabs = const [
    MenuItem(id: 'home', label: '首页', icon: Icons.home, page: HomePage()),
    MenuItem(id: 'profile', label: '我的', icon: Icons.person, page: ProfilePage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_idx].page,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        items: _tabs
            .map((t) =>
                BottomNavigationBarItem(icon: Icon(t.icon), label: t.label))
            .toList(),
      ),
    );
  }
}
