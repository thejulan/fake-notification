import 'package:flutter/services.dart';

class InstalledApp {
  final String name;
  final String packageName;
  final Uint8List icon;

  InstalledApp({
    required this.name,
    required this.packageName,
    required this.icon,
  });

  factory InstalledApp.fromMap(Map<Object?, Object?> map) {
    return InstalledApp(
      name: map['name'] as String,
      packageName: map['packageName'] as String,
      icon: map['icon'] as Uint8List,
    );
  }
}

class NativeApi {
  static const MethodChannel _channel = MethodChannel('com.fakenotification/backend');

  static Future<List<InstalledApp>> getInstalledApps({bool includeSystem = false}) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getInstalledApps', {
        'includeSystem': includeSystem,
      });
      return result.map((e) => InstalledApp.fromMap(e as Map<Object?, Object?>)).toList();
    } catch (e) {
      print("Failed to get apps: \$e");
      return [];
    }
  }

  static Future<bool> sendFakeNotification({
    required String packageName,
    required String appName,
    required String title,
    required String text,
    int delayMillis = 0,
  }) async {
    try {
      final bool result = await _channel.invokeMethod('sendFakeNotification', {
        'packageName': packageName,
        'appName': appName,
        'title': title,
        'text': text,
        'delayMillis': delayMillis,
      });
      return result;
    } catch (e) {
      print("Failed to send notification: \$e");
      return false;
    }
  }

  static Future<bool> checkPermissions() async {
    try {
      final bool result = await _channel.invokeMethod('checkPermissions');
      return result;
    } catch (e) {
      print("Failed to check permissions: \$e");
      return false;
    }
  }
}
