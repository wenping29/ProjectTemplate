import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储：当前 token + 多账号列表（用于账号切换）。
class StorageService {
  static const _tokenKey = 'token';
  static const _accountsKey = 'accounts';

  final SharedPreferences _sp;
  StorageService(this._sp);

  static Future<StorageService> create() async =>
      StorageService(await SharedPreferences.getInstance());

  Future<void> saveToken(String token) => _sp.setString(_tokenKey, token);
  String? get token => _sp.getString(_tokenKey);
  Future<void> clearToken() => _sp.remove(_tokenKey);

  Future<void> saveAccounts(List<Map<String, String>> list) async {
    await _sp.setStringList(
      _accountsKey,
      list.map((m) => jsonEncode(m)).toList(),
    );
  }

  Future<List<Map<String, String>>> loadAccounts() async {
    final raw = _sp.getStringList(_accountsKey) ?? [];
    return raw
        .map((e) => Map<String, String>.from(jsonDecode(e) as Map))
        .toList();
  }
}
