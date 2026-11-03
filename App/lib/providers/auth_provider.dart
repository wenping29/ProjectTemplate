import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';

/// 鉴权与账号状态（含多账号切换 / 注销）。
class AuthProvider extends ChangeNotifier {
  final StorageService _storage;
  final AuthService _auth;
  User? _user;
  List<Map<String, String>> _accounts = [];

  AuthProvider({required StorageService storage, required AuthService auth})
      : _storage = storage,
        _auth = auth;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  List<Map<String, String>> get accounts => _accounts;

  Future<void> init() async {
    _accounts = await _storage.loadAccounts();
    final token = _storage.token;
    if (token != null && _accounts.isNotEmpty) {
      final cur = _accounts.first; // 简化：以列表首个为当前账号
      _user = User(
        id: cur['userId']!,
        username: cur['username']!,
        displayName: cur['displayName'],
        avatarUrl: cur['avatarUrl'],
        roleId: cur['roleId'] ?? '',
      );
    }
    notifyListeners();
  }

  Future<void> _saveAccount(String token, User u) async {
    _accounts.removeWhere((a) => a['userId'] == u.id);
    _accounts.add({
      'token': token,
      'userId': u.id,
      'username': u.username,
      'displayName': u.displayName ?? '',
      'avatarUrl': u.avatarUrl ?? '',
      'roleId': u.roleId,
    });
    await _storage.saveAccounts(_accounts);
  }

  Future<void> login(String username, String password) async {
    final (token, u) = await _auth.login(username, password);
    await _storage.saveToken(token);
    await _saveAccount(token, u);
    _user = u;
    notifyListeners();
  }

  Future<void> register(String username, String email, String password) async {
    final (token, u) = await _auth.register(username, email, password);
    await _storage.saveToken(token);
    await _saveAccount(token, u);
    _user = u;
    notifyListeners();
  }

  /// 账号切换
  Future<void> switchTo(String userId) async {
    final a = _accounts.firstWhere((e) => e['userId'] == userId);
    await _storage.saveToken(a['token']!);
    _user = User(
      id: a['userId']!,
      username: a['username']!,
      displayName: a['displayName'],
      avatarUrl: a['avatarUrl'],
      roleId: a['roleId'] ?? '',
    );
    notifyListeners();
  }

  /// 账户退出
  Future<void> logout() async {
    await _storage.clearToken();
    _user = null;
    notifyListeners();
  }

  /// 账号注销（停用当前账号，并移除本机记录）
  Future<void> deactivate() async {
    await _auth.deactivateAccount();
    _accounts.removeWhere((a) => a['userId'] == _user?.id);
    await _storage.saveAccounts(_accounts);
    await _storage.clearToken();
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile(
      {String? displayName, String? avatarUrl, String? phone}) async {
    await _auth.updateProfile(
        displayName: displayName, avatarUrl: avatarUrl, phone: phone);
    if (_user != null) {
      _user = _user!.copyWith(
          displayName: displayName, avatarUrl: avatarUrl, phone: phone);
      final idx = _accounts.indexWhere((a) => a['userId'] == _user!.id);
      if (idx >= 0) {
        _accounts[idx] = {
          ..._accounts[idx],
          'displayName': displayName ?? _accounts[idx]['displayName']!,
          'avatarUrl': avatarUrl ?? _accounts[idx]['avatarUrl']!,
        };
        await _storage.saveAccounts(_accounts);
      }
      notifyListeners();
    }
  }

  Future<String> uploadAvatar(File file) => _auth.uploadAvatar(file);
}
