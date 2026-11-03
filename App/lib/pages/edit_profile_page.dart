import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _displayName = TextEditingController();
  final _phone = TextEditingController();
  File? _avatar;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = context.read<AuthProvider>().user;
    _displayName.text = u?.displayName ?? '';
    _phone.text = u?.phone ?? '';
  }

  Future<void> _pickAvatar() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (f != null) setState(() => _avatar = File(f.path));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      String? avatarUrl;
      if (_avatar != null) {
        avatarUrl = await context.read<AuthProvider>().uploadAvatar(_avatar!);
      }
      await context.read<AuthProvider>().updateProfile(
            displayName: _displayName.text,
            phone: _phone.text,
            avatarUrl: avatarUrl,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('保存失败')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final avatarUrl = user?.avatarUrl;

    ImageProvider? bg;
    if (_avatar != null) {
      bg = FileImage(_avatar!);
    } else if (avatarUrl != null) {
      bg = NetworkImage(avatarUrl);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('修改个人信息')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAvatar,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: bg,
                child: bg == null ? const Icon(Icons.person, size: 40) : null,
              ),
            ),
            const SizedBox(height: 8),
            const Text('点击头像上传', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
                controller: _displayName,
                decoration: const InputDecoration(labelText: '显示名称')),
            TextField(
                controller: _phone,
                decoration: const InputDecoration(labelText: '手机号')),
            const SizedBox(height: 24),
            _saving
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _save, child: const Text('保存')),
          ],
        ),
      ),
    );
  }
}
