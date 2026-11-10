import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // 通用设置
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '通用设置',
              style: TextStyle(fontSize: 14,  fontWeight: FontWeight.w500),
            ),
          ),
          SwitchListTile(
            title: const Text('深色模式'),
            value: false,
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('深色模式已${value ? '开启' : '关闭'}')),
              );
            },
            secondary: const Icon(Icons.dark_mode, color: Colors.blue),
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          //  margin: const EdgeInsets.only(bottom: 8),
          ),
          SwitchListTile(
            title: const Text('消息通知'),
            value: true,
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('消息通知已${value ? '开启' : '关闭'}')),
              );
            },
            secondary: const Icon(Icons.notifications, color: Colors.green),
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
           // margin: const EdgeInsets.only(bottom: 8),
          ),
          // 缓存清理
          ListTile(
            leading: const Icon(Icons.cleaning_services, color: Colors.orange),
            title: const Text('清理缓存'),
            subtitle: const Text('当前缓存：12.5MB'),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存清理成功')),
              );
            },
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
           // margin: const EdgeInsets.only(bottom: 8),
          ),
          // 关于设置
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '关于',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.update, color: Colors.purple),
            title: const Text('检查更新'),
            subtitle: const Text('当前版本：v1.0.0'),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('当前已是最新版本')),
              );
            },
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
           // margin: const EdgeInsets.only(bottom: 8),
          ),
        ],
      ),
    );
  }
}