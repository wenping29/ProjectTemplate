import 'package:flutter/material.dart';

class AccountSecurityPage extends StatelessWidget {
  const AccountSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户安全'),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 16),
          _buildSecurityItem('修改密码', Icons.lock_outlined, () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('暂未实现修改密码功能')),
            );
          }),
          _buildSecurityItem('绑定手机', Icons.phone_outlined, () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('暂未实现绑定手机功能')),
            );
          }),
          _buildSecurityItem('登录设备管理', Icons.devices_outlined, () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('暂未实现登录设备管理功能')),
            );
          }),
          _buildSecurityItem('登录日志', Icons.history_outlined, () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('暂未实现登录日志查询功能')),
            );
          }),
          const SizedBox(height: 24),
          const Divider(),
          // 安全开关
          SwitchListTile(
            title: const Text('人脸识别登录'),
            subtitle: const Text('开启后登录需要验证人脸'),
            value: false,
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('人脸识别登录已${value ? '开启' : '关闭'}')),
              );
            },
            secondary: const Icon(Icons.face, color: Colors.purple),
          ),
          SwitchListTile(
            title: const Text('异地登录提醒'),
            subtitle: const Text('异地登录时发送短信提醒'),
            value: true,
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('异地登录提醒已${value ? '开启' : '关闭'}')),
              );
            },
            secondary: const Icon(Icons.notifications, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange, size: 24),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
      onTap: onTap,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
     // margin: const EdgeInsets.only(bottom: 8),
    );
  }
}