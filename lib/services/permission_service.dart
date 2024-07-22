import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  Map<String, dynamic> deviceInfoData = {};

  Future<void> checkPermissions() async {
    if (Platform.isIOS) {
      IosDeviceInfo info = await _deviceInfo.iosInfo;
      deviceInfoData = info.data;
    } else {
      AndroidDeviceInfo info = await _deviceInfo.androidInfo;
      deviceInfoData = info.data;
    }

    await _requestPermission(Permission.location);
    await _requestPermission(Permission.activityRecognition);
    await _requestPermission(Permission.storage);
  }

  Future<void> _requestPermission(Permission permission) async {
    PermissionStatus status = await permission.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Map<String, dynamic> getDeviceInfo() {
    return deviceInfoData;
  }
}
