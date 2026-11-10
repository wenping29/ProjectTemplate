/// 全局配置。
class AppConfig {
  /// 后端 API 地址。
  /// - Android 模拟器访问本机需用 10.0.2.2
  /// - iOS 模拟器 / 真机用电脑局域网 IP（如 http://192.168.x.x:5001/api）
  static const String apiBaseUrl = 'http://localhost:5000/api';

  static const String loginPath = '/auth/login';
  static const String registerPath = '/auth/register';
  static const String profilePath = '/users/me/profile';
  static const String menusTreePath = '/menus/tree';

  /// 统一响应结构：{ code, message, data }
  static const int successCode = 0;
}
