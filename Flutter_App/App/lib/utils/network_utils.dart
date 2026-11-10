import 'dart:convert';
import 'package:http/http.dart' as http;

// 服务端基础地址（替换为你的后端IP/域名）
// const String baseUrl = 'http://8.136.202.27:80/test/api';
const String baseUrl = 'http://localhost:5003/api';

// 存储JWT令牌（模拟本地存储，生产可用SharedPreferences）
String? _token;
// network_utils.dart 中新增
int? _currentUserId; // 存储当前登录用户ID
String? _currentUsername; // 存储当前用户名

// 登录成功后存储用户信息
void setUserInfo(int userId, String username) {
  _currentUserId = userId;
  _currentUsername = username;
}

// 获取当前用户ID
int? getCurrentUserId() {
  return _currentUserId;
}

// 设置令牌
void setToken(String token) {
  _token = token.trim(); // 移除首尾空格
}

// 清除令牌
void clearToken() {
  _token = null;
}

// 获取令牌（公共方法）
String? getToken() {
  return _token;
}

// 检查是否登录（公共方法）
bool isLoggedIn() {
  //print(_token);
  return _token != null && _token!.isNotEmpty;
}

// 通用网络请求方法
class NetworkUtils {
  // GET请求
  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    try {
      String? token = getToken();
      final url = Uri.parse('$baseUrl/$path');
      final requestHeaders = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };
      final response = await http.get(url, headers: requestHeaders);
      return _handleResponse(response);
    } catch (e) {
      return {'code': -1, 'message': '网络异常：$e', 'data': null};
    }
  }

  // POST请求
  static Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/$path');
      String? token = getToken();
      final requestHeaders = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };

      final response = await http.post(
        url,
        headers: requestHeaders,
        body: data != null ? jsonEncode(data) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'code': -1, 'message': '网络异常：$e', 'data': null};
    }
  }

  // 统一处理响应
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> result = jsonDecode(response.body);
      // 401未授权：清除令牌并返回
      if (response.statusCode == 401) {
        clearToken();
        return {'code': 401, 'message': '登录已过期，请重新登录', 'data': null};
      }
      return result;
    } catch (e) {
      return {
        'code': response.statusCode,
        'message': '解析数据失败：$e',
        'data': null,
      };
    }
  }
}

class NetworkServices {
  // network_utils.dart 中新增
  static Map<String, dynamic> _convertToCamelCase(Map<String, dynamic> data) {
    final Map<String, dynamic> result = {};
    data.forEach((key, value) {
      if (key.isNotEmpty) {
        final String camelKey = key[0].toLowerCase() + key.substring(1);
        result[camelKey] = value;
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  // 查询我的收藏
  static Future<Map<String, dynamic>> getMyCollections({
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    try {
      final url =
          'Collection/MyCollections?pageIndex=$pageIndex&pageSize=$pageSize';
      final Map<String, String> requestHeaders = {
        'Content-Type': 'application/json; charset=utf-8',
      };
      if (_token != null && _token!.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $_token';
      }
      final res = await NetworkUtils.get(url, headers: requestHeaders);
      return res;
    } catch (e) {
      return {'code': -1, 'message': '网络异常：$e', 'data': null};
    }
  }

  /// 查询我的好友列表
  static Future<Map<String, dynamic>> getMyFriends() async {
    try {
      final url = 'Friend/MyFriends';
      final Map<String, String> requestHeaders = {
        'Content-Type': 'application/json; charset=utf-8',
      };
      // 携带JWT令牌
      if (_token != null && _token!.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $_token';
      }
      final res = await NetworkUtils.get(url, headers: requestHeaders);
      return res;
    } catch (e) {
      return {'code': -1, 'message': '网络异常：$e', 'data': null};
    }
  }

  /// 获取当前用户信息
  static Future<Map<String, dynamic>> getMyUserInfo() async {
    try {
      final url = 'User/MyInfo';
      final Map<String, String> requestHeaders = {
        'Content-Type': 'application/json; charset=utf-8',
      };
      // 携带JWT令牌
      if (_token != null && _token!.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $_token';
      }
      final res = await NetworkUtils.get(url, headers: requestHeaders);
      return res;
    } catch (e) {
      return {'code': -1, 'message': '网络异常：$e', 'data': null};
    }
  }

  /// 获取朋友圈列表（分页）
  static Future<Map<String, dynamic>> getMomentList({
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    try {
      final url = 'Moment/MyMomentList?pageIndex=$pageIndex&pageSize=$pageSize';
      final Map<String, String> requestHeaders = {
        'Content-Type': 'application/json; charset=utf-8',
      };
      // 携带JWT令牌
      if (_token != null && _token!.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $_token';
      }
      final res = await NetworkUtils.get(url, headers: requestHeaders);
      return res;
    } catch (e) {
      return {'code': -1, 'message': '网络异常：$e', 'data': null};
    }
  }
}
