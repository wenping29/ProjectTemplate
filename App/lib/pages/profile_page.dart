import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/routes.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final avatarUrl = user?.avatarUrl;

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(height: 8),
          Center(child: Text(user?.displayName ?? user?.username ?? '')),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('修改个人信息'),
            onTap: () => Navigator.pushNamed(context, Routes.editProfile),
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('账号切换'),
            onTap: () => _showSwitch(context, auth),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('账户退出'),
            onTap: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, Routes.login);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('账号注销'),
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () => _confirmDeactivate(context, auth),
          ),
        ],
      ),
    );
  }

  void _showSwitch(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        children: auth.accounts
            .map((a) => ListTile(
                  title: Text(a['username'] ?? ''),
                  subtitle: Text(a['displayName'] ?? ''),
                  onTap: () async {
                    await auth.switchTo(a['userId']!);
                    if (context.mounted) Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }

  void _confirmDeactivate(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认注销账号？'),
        content: const Text('注销后该账号将从本设备移除且不可恢复。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await auth.deactivate();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, Routes.login);
              }
            },
            child: const Text('注销'),
          ),
        ],
      ),
    );
  }
}
