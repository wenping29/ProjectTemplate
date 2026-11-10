import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: Center(
        child: Text('欢迎，${user?.displayName ?? user?.username ?? '访客'}！'),
      ),
    );
  }
}
