import 'dart:io';
import 'package:dio/dio.dart';
import 'config/app_config.dart';
import 'models/user.dart';
import 'services/api_service.dart';

class AuthService {
  final ApiService _api;
  AuthService(this._api);
  Dio get _dio => _api.dio;

  /// 登录：返回 (token, 用户信息)
  Future<(String, User)> login(String username, String password) async {
    final r = await _dio.post(AppConfig.loginPath,
        data: {'username': username, 'password': password});
    final d = r.data['data'];
    return (
      d['accessToken'] as String,
      User(
        id: d['userId'],
        username: d['username'],
        displayName: d['displayName'],
        roleId: d['roleId'],
      )
    );
  }

  Future<(String, User)> register(
      String username, String email, String password) async {
    final r = await _dio.post(AppConfig.registerPath,
        data: {'username': username, 'email': email, 'password': password});
    final d = r.data['data'];
    return (
      d['accessToken'] as String,
      User(
        id: d['userId'],
        username: d['username'],
        displayName: d['displayName'],
        roleId: d['roleId'],
      )
    );
  }

  Future<void> updateProfile(
      {String? displayName, String? avatarUrl, String? phone}) async {
    await _dio.put(AppConfig.profilePath, data: {
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'phone': phone,
    });
  }

  /// 上传头像（需服务端提供 POST /api/users/me/avatar 接口）
  Future<String> uploadAvatar(File file) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });
    final r = await _dio.post('/users/me/avatar', data: form);
    return r.data['data']['url'] as String;
  }

  /// 账号注销（停用/删除当前账号）
  Future<void> deactivateAccount() async {
    await _dio.delete('/users/me');
  }
}
