import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/permission.dart';
import 'register_page.dart';
import 'forgot_pwd_page.dart';
import 'main_nav_page.dart';
import '../utils/network_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // 修复后的登录逻辑
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // 构建请求参数
        final requestData = {
          'Account': _accountController.text.trim(),
          'Password': _passwordController.text.trim(),
        };

        // 调用登录API
        final response = await NetworkUtils.post(
          'Auth/Login',
          data: requestData,
        );

        // 无论是否成功，先结束加载状态
        if (mounted) {
          setState(() => _isLoading = false);
        }

        // 登录成功处理（核心修复）
        if (response['code'] == 200) {
          // 1. 优先存储令牌（确保后续接口可用）
          final token = response['data'] ?? '';
          if (token.isNotEmpty) {
            setToken(token);
          }
          print(token);
          // 2. 使用WidgetsBinding确保在UI帧中执行跳转
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // 强制替换路由栈，确保无法返回登录页
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainNavPage()),
                (Route<dynamic> route) => false, // 清除所有之前的路由
              );
              // 显示成功提示
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('登录成功！'),
                  backgroundColor: Colors.green,
                ),
              );
            });
          }
        } else {
          // 登录失败：显示错误信息
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${response['message'] ?? '登录失败'}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        // 捕获所有异常，确保加载状态重置
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('登录异常：$e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initNetworkState(); // 初始化网络权限状态
    //initCameraPermissionState();
    //checkNetworkPermission();
  }

  Future<void> initCameraPermissionState() async {
    //print("获取网络权限");
    try {
      await PermissionUtils.requestCameraPermission();
      //print("获取网络权限成功");
    } catch (e) {
      // 如果获取失败，记录错误信息
      ///print("如果获取失败，记录错误信息");
    }
  }

  Future<void> checkNetworkPermission() async {
    //_showDialog();
    //print("检查网络权限");
    // 检查网络权限（根据需求选择具体权限，如位置/网络等）
    final status = await Permission.phone.status;
    if (status.isDenied) {
      await Permission.location.request();
      //print("检查网络权限OK");
    }
  }

  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('弹窗标题'),
        content: const Text("networkType"),
        actions: [
          TextButton(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('确定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> initNetworkState() async {
    PermissionUtils.checkInitialNetwork();
    // 更新 UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '欢迎登录',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // 账号输入
              TextFormField(
                controller: _accountController,
                decoration: InputDecoration(
                  labelText: '账号/邮箱',
                  hintText: '请输入账号或邮箱',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value!.isEmpty ? '请输入账号' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // 密码输入
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: '密码',
                  hintText: '请输入密码',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value!.length < 6 ? '密码不少于6位' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 8),

              // 找回密码
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPwdPage(),
                          ),
                        ),
                  child: const Text('忘记密码？'),
                ),
              ),
              const SizedBox(height: 24),

              // 登录按钮
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('登录', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 32),

              FloatingActionButton(
                child: const Text('更新', style: TextStyle(fontSize: 18)),
                onPressed: () {
                  //_showDialog();
                  initNetworkState(); // 点击按钮重新获取网络权限状态
                  //checkNetworkPermission();
                },
              ),
              const SizedBox(height: 32),
              FloatingActionButton(
                child: const Text('摄像头权限', style: TextStyle(fontSize: 18)),
                onPressed: () {
                  initCameraPermissionState(); // 点击按钮重新获取网络权限状态
                },
              ),
              // 注册入口
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('还没有账号？'),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          ),
                    child: const Text('立即注册'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
