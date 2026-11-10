import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  // 1. 定义MethodChannel（和原生端保持一致）
  static const MethodChannel _operatorChannel = MethodChannel(
    'network_operator_channel',
  );
  // 2. 申请权限（获取运营商必需）
  static Future<bool> requestPhonePermission() async {
    final status = await Permission.phone.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      final result = await Permission.phone.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  // 3. 结合connectivity_plus：先判断网络类型，再获取运营商
  static Future<Map<String, dynamic>> getNetworkInfo() async {
    // 第一步：用connectivity_plus判断网络类型
    final connectivityResult = await Connectivity().checkConnectivity();
    String networkType = "none";
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      networkType = "cellular"; // 蜂窝网络
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      networkType = "wifi"; // WiFi（无运营商信息）
    }
    // 第二步：仅蜂窝网络时获取运营商
    String operatorName = "未知";
    if (networkType == "cellular") {
      final hasPermission = await requestPhonePermission();
      if (hasPermission) {
        try {
          operatorName = await _operatorChannel.invokeMethod('getOperatorName');
        } catch (e) {
          operatorName = "获取失败：$e";
        }
      } else {
        operatorName = "无手机权限";
      }
    }
    return {
      "networkType": networkType, // 网络类型：cellular/wifi/none
      "operatorName": operatorName, // 运营商：移动/联通/电信/未知
    };
  }

  static Future<void> checkInitialNetwork() async {
    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.mobile) {
      print('蜂窝网络已连接');
    } else if (result == ConnectivityResult.wifi) {
      print('WiFi 已连接');
    }
    if (result == ConnectivityResult.none) {
      print('无网络连接');
    } else {
      Map<String, dynamic> info = await getNetworkInfo();
      // 获取网络类型（蜂窝/WiFi/无网）
      String networkType = info["networkType"];
      print('当前网络类型: $networkType');
      // 获取网络运营商（移动/联通/电信）
      String carrier = info["operatorName"];
      print('当前网络运营商: $carrier');
    }
  }

  static Future checkCameraPermission() async {
    final PermissionStatus status = await Permission.camera.status;
    if (status.isGranted) {
      print('相机权限已授予');
      // 执行相机相关操作
    } else if (status.isDenied) {
      print('相机权限被拒绝，可再次请求');
      // 引导用户请求权限
    } else if (status.isPermanentlyDenied) {
      print('相机权限被永久拒绝，需引导到设置页');
      // 跳转应用设置页
      await openAppSettings();
    } else if (status.isRestricted) {
      print('相机权限受限（系统级限制）');
    } else if (status.isLimited) {
      print('相机权限有限授权（iOS 特有）');
    }
  }

  // 请求相机权限
  static Future requestCameraPermission() async {
    final PermissionStatus status = await Permission.camera.status;
    // 已授予则直接返回
    if (status.isGranted) return;
    // 未授予则请求权限
    final PermissionStatus requestStatus = await Permission.camera.request();
    // 处理请求结果
    switch (requestStatus) {
      case PermissionStatus.granted:
        print('相机权限请求成功');
        break;
      case PermissionStatus.denied:
        print('相机权限请求被拒绝');
        break;
      case PermissionStatus.permanentlyDenied:
        print('相机权限被永久拒绝，引导到设置页');
        await openAppSettings();
        break;
      default:
        print('相机权限请求失败：$requestStatus');
    }
  }

  // 带回调的权限请求（以定位权限为例）
  static Future requestLocationWithCallbacks() async {
    await Permission.locationWhenInUse
        .onGrantedCallback(() {
          print('定位权限已授予，执行定位操作');
          // 调用定位相关方法
        })
        .onDeniedCallback(() {
          print('定位权限被拒绝，提示用户需要权限才能使用该功能');
        })
        .onPermanentlyDeniedCallback(() {
          print('定位权限被永久拒绝，引导到设置页');
          openAppSettings();
        })
        .onRestrictedCallback(() {
          print('定位权限受限，无法使用定位功能');
        })
        .onLimitedCallback(() {
          print('定位权限有限授权，部分功能可用');
        })
        .request(); // 执行请求
  }

  // 检查定位服务状态
  static Future checkLocationServiceStatus() async {
    final PermissionStatus locationStatus =
        await Permission.locationWhenInUse.status;
    if (locationStatus.isGranted) {
      // 检查定位服务是否开启
      final ServiceStatus serviceStatus =
          await Permission.locationWhenInUse.serviceStatus;
      if (serviceStatus.isEnabled) {
        print('定位服务已开启，可执行定位操作');
      } else {
        print('定位服务未开启，引导用户开启');
        // 部分平台可直接跳转到服务开启页（需配合原生代码，或提示用户手动开启）
      }
    } else {
      print('定位权限未授予');
    }
  }

  // 带 Rationale 提示的权限请求（Android 特有）
  static Future requestContactsWithRationale() async {
    final PermissionStatus status = await Permission.contacts.status;
    if (status.isGranted) return;
    // 判断是否需要显示 Rationale 提示
    final bool shouldShowRationale =
        await Permission.contacts.shouldShowRequestRationale;
    if (shouldShowRationale) {
      // 显示 Rationale 提示（如通过 Dialog 告知用户需要通讯录权限的原因）
      print('需要通讯录权限用于同步联系人信息，是否授权？');
      // 显示 Dialog 后，用户确认则请求权限
    }
    // 执行权限请求
    final PermissionStatus requestStatus = await Permission.contacts.request();
    if (requestStatus.isGranted) {
      print('通讯录权限请求成功');
    } else {
      print('通讯录权限请求失败');
    }
  }

  // 差异化请求相册权限（适配 iOS/Android 不同版本）
  static Future requestPhotoPermission() async {
    Permission photoPermission;
    if (Platform.isIOS) {
      // iOS 统一使用 Permission.photos
      photoPermission = Permission.photos;
    } else if (Platform.isAndroid) {
      // Android 13+ 使用 Permission.photos，13- 使用 Permission.storage
      if (await Permission.photos.isGranted) {
        photoPermission = Permission.photos;
      } else {
        photoPermission = Permission.storage;
      }
    } else {
      print('不支持的平台');
      return;
    }
    // 执行请求
    final PermissionStatus status = await photoPermission.request();
    if (status.isGranted) {
      print('相册权限请求成功');
    }
  }

  static Future requestStoragePermission() async {
    // 获取当前平台
    // 1. 先请求前台定位权限
    await Permission.locationWhenInUse.request();
    // 2. 前台权限授予后，再请求后台定位权限
    await Permission.locationAlways.request();
  }

  static Future GetCameraPermission() async {
    await Permission.camera.request();
  }

  static Future GetStoragePermission() async {
    await Permission.storage.request();
  }

  static Future GetPhotosPermission() async {
    await Permission.photos.request();
  }

  static Future GetContactsPermission() async {
    await Permission.contacts.request();
  }

  static Future GetLocationWhenInUsePermission() async {
    await Permission.locationWhenInUse.request();
  }

  static Future GetPhonePermission() async {
    await Permission.phone.request();
  }

  static Future GetBluetoothPermission() async {
    await Permission.bluetooth.request();
  }

  static Future GetBluetoothScanPermission() async {
    await Permission.bluetoothScan.request();
  }

  static Future GetAudioPermission() async {
    await Permission.audio.request();
  }

  static Future GetSpeechPermission() async {
    await Permission.speech.request();
  }

  static Future GetSmsPermission() async {
    await Permission.sms.request();
  }

  static Future GetCalendarPermission() async {
    await Permission.calendar.request();
  }

  static Future GetLocationPermission() async {
    await Permission.location.request();
  }

  static Future GetLocationAlwaysPermission() async {
    await Permission.locationAlways.request();
  }

  static Future GetSensorsPermission() async {
    await Permission.sensors.request();
  }

  static Future GetSensorsAlwaysPermission() async {
    await Permission.sensorsAlways.request();
  }

  static Future GetVideosPermission() async {
    await Permission.videos.request();
  }

  /*
    mediaLibrary,
    microphone,
    photosAddOnly,
    reminders,
    ignoreBatteryOptimizations,
    notification,
    accessMediaLocation,
    activityRecognition,
    unknown,
    manageExternalStorage,
    systemAlertWindow,
    requestInstallPackages,
    appTrackingTransparency,
    criticalAlerts,
    accessNotificationPolicy,
    bluetoothAdvertise,
    bluetoothConnect,
    nearbyWifiDevices,
    scheduleExactAlarm,
    sensorsAlways,
    calendarWriteOnly,
    calendarFullAccess,
    assistant,
    backgroundRefresh,
  */
}
