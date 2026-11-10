import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class ApiService {
  final Dio dio;
  ApiService(this.dio);

  static ApiService create(StorageService storage) {
    final d = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
    d.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final t = storage.token;
        if (t != null) options.headers['Authorization'] = 'Bearer $t';
        return handler.next(options);
      },
      onError: (error, handler) {
        // 401 交给调用方处理（跳转登录）
        return handler.next(error);
      },
    ));
    return ApiService(d);
  }
}
