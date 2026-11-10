import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/pages/map_page.dart';
import 'pages/login_page.dart';
import 'pages/main_nav_page.dart';
import 'pages/message_page.dart';
import 'pages/friend_page.dart';
import 'pages/moments_page.dart';
import 'pages/mine_page.dart';
import 'pages/forgot_pwd_page.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info/device_info.dart';

void GetOS() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  print('iOS设备唯一标识：${iosInfo.identifierForVendor}');

  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  print('Android设备唯一标识：${androidInfo.androidId}');
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  var uuid = Uuid();
  print(uuid.v4());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSansSC',
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const MainNavPage(),
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      // 命名路由表
      routes: {
        '/login': (context) => const LoginPage(),
        '/main': (context) => const MainNavPage(),
        '/message': (context) => const MessagePage(),
        '/mine': (context) => const MinePage(),
        '/friend': (context) => const FriendPage(),
        '/moments': (context) => const MomentPage(),
        '/forgot_pwd_page': (context) => const ForgotPwdPage(),
        '/map': (context) => const AddMapPage(),
      },
      // 未知路由处理
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const LoginPage());
      },
    );
  }
}
