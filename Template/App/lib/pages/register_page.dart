import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/routes.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _user = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await context
          .read<AuthProvider>()
          .register(_user.text, _email.text, _pass.text);
      if (mounted) Navigator.pushReplacementNamed(context, Routes.home);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('注册失败')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _user, decoration: const InputDecoration(labelText: '用户名')),
            TextField(controller: _email, decoration: const InputDecoration(labelText: '邮箱')),
            TextField(
                controller: _pass,
                decoration: const InputDecoration(labelText: '密码'),
                obscureText: true),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _submit, child: const Text('注册')),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, Routes.login),
              child: const Text('已有账号？去登录'),
            ),
          ],
        ),
      ),
    );
  }
}
