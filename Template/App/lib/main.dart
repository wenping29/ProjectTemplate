import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'providers/auth_provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 组装依赖（手写骨架：实际运行前需安装 Flutter SDK 并执行 flutter pub get）
  final storage = await StorageService.create();
  final api = ApiService.create(storage);
  final auth = AuthService(api);
  final provider = AuthProvider(storage: storage, auth: auth);
  await provider.init();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: provider)],
      child: const App(),
    ),
  );
}
