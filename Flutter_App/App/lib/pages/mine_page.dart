import 'package:flutter/material.dart';
import '../utils/list_utils.dart';
import 'login_page.dart';
import 'personal_info_page.dart'; // 个人信息页
import 'payment_manage_page.dart'; // 支付管理页
import 'account_security_page.dart'; // 账户安全页
import 'my_collection_page.dart'; // 我的收藏页
import 'settings_page.dart'; // 设置页
import 'about_page.dart'; // 关于页
import '../utils/network_utils.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  // 1. 定义所有功能菜单数据（标题、图标、颜色、目标页面）
  final List<Map<String, dynamic>> _menuList = [
    {
      'title': '个人信息',
      'icon': Icons.person_outline,
      'color': Colors.blue,
      'page': const PersonalInfoPage(),
    },
    {
      'title': '支付管理',
      'icon': Icons.payment_outlined,
      'color': Colors.green,
      'page': const PaymentManagePage(),
    },
    {
      'title': '账户安全',
      'icon': Icons.security_outlined,
      'color': Colors.orange,
      'page': const AccountSecurityPage(),
    },
    {
      'title': '我的收藏',
      'icon': Icons.favorite_border,
      'color': Colors.red,
      'page': const MyCollectionPage(),
    },
    {
      'title': '设置',
      'icon': Icons.settings_outlined,
      'color': Colors.grey,
      'page': const SettingsPage(),
    },
    {
      'title': '关于',
      'icon': Icons.info_outline,
      'color': Colors.purple,
      'page': const AboutPage(),
    },
  ];
  // 用户信息（强类型Map）
  Map<String, dynamic> _userInfo = {};
  // 加载用户信息
  Future<void> _loadUserInfo() async {
    setState(() {
      // _isLoading = true;
      // _errorMsg = '';
    });

    try {
      final response = await NetworkServices.getMyUserInfo();
      if (response['code'] == 200) {
        setState(() {
          _userInfo = response['data'] is Map ? response['data'] : {};
          //print(_userInfo);
          // _isLoading = false;
        });
      } else {
        setState(() {
          // _errorMsg = response['message'] ?? '获取用户信息失败';
          // _isLoading = false;
        });
      }
    } catch (e) {
      // setState(() {
      //   // _errorMsg = '网络异常：$e';
      //   // _isLoading = false;
      // });
    }
  }

  // 2. 退出登录逻辑（清空令牌+跳转登录页）
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('是否确定退出当前账号？退出后需要重新登录'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 清除令牌
              clearToken();
              // 关闭弹窗
              Navigator.pop(context);
              // 跳转到登录页并清空路由栈（无法返回）
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text('退出', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // 页面初始化加载用户信息
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 安全取值
    String username = MapUtils.getString(_userInfo,'Username',defaultValue: '未知用户',);
    String phone = MapUtils.getString(_userInfo, 'Phone', defaultValue: '未绑定');
    String registerTime = MapUtils.getString(_userInfo,'RegisterTime',defaultValue: '未知',);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 顶部用户信息栏（固定样式）
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4285F4), Color(0xFF4285F4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 用户头像
                const CircleAvatar(
                  radius: 45,
                  backgroundImage: AssetImage(
                    'assets/avatar_default.png',
                  ), // 替换为你的默认头像路径
                ),
                const SizedBox(height: 12),
                // 用户名（后续可从Token解析）
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // 补充信息
                Text(
                  '手机号：$phone | 注册时间：$registerTime',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),

                // 登录状态
                Text(
                  isLoggedIn() ? '已登录 · ID: 1001' : '未登录',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 功能菜单列表
          ..._menuList.map((menu) {
            return _buildMenuItem(
              title: menu['title'],
              icon: menu['icon'],
              color: menu['color'],
              onTap: () {
                // 菜单点击跳转逻辑
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => menu['page']),
                );
              },
            );
          }).toList(),

          // 退出登录按钮（单独样式）
          _buildMenuItem(
            title: '退出登录',
            icon: Icons.logout_outlined,
            color: Colors.red,
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  // 通用菜单项构建方法（复用样式）
  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[200]!,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}
