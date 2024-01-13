// ignore_for_file: file_names

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:patikmobile/api/static_variables.dart';

class DeviceProvider {
  static String getPhoneId() {
    if (StaticVariables.PhoneID.isEmpty) {
      var deviceInfo = DeviceInfoPlugin();
      if (Platform.isIOS) {
        // import 'dart:io'
        deviceInfo.iosInfo.then(
            (value) => StaticVariables.PhoneID = value.identifierForVendor!);
      } else if (Platform.isAndroid) {
        deviceInfo.androidInfo
            .then((value) => StaticVariables.PhoneID = value.id);
      }
    }
    return StaticVariables.PhoneID;
  }
}
