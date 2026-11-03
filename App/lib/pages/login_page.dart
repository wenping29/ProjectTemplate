import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/routes.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _user = TextEditingController(text: 'admin');
  final _pass = TextEditingController(text: 'Admin@123456');
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().login(_user.text, _pass.text);
      if (mounted) Navigator.pushReplacementNamed(context, Routes.home);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('登录失败')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
                controller: _user, decoration: const InputDecoration(labelText: '用户名')),
            TextField(
                controller: _pass,
                decoration: const InputDecoration(labelText: '密码'),
                obscureText: true),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _submit, child: const Text('登录')),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, Routes.register),
              child: const Text('没有账号？去注册'),
            ),
          ],
        ),
      ),
    );
  }
}
