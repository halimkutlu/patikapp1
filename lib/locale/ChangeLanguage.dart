// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final List locale = [
  {'name': 'ENGLISH', 'locale': Locale('en', 'US'), 'code': 'en-US'},
  {'name': 'ಕನ್ನಡ', 'locale': Locale('kn', 'IN'), 'code': 'en-US'},
  {'name': 'हिंदी', 'locale': Locale('hi', 'IN'), 'code': 'en-US'},
  {'name': 'Türkçe', 'locale': Locale('tr', 'TR'), 'code': 'tr-TR'},
  {'name': 'Deutsche Sprache', 'locale': Locale('de', 'DE'), 'code': 'de-DE'},
];
updateLanguage(Locale locale) async {
  Get.updateLocale(locale);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("language_code", locale.languageCode);
  prefs.setString("countryCode", locale.countryCode!);
  // Sayfayı yeniden oluşturarak getLanguage fonksiyonunu tekrar çağır
  // Get.back();
}

getLanguage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var lc = prefs.getString("language_code");
  var cc = prefs.getString("countryCode");
  if (lc != null && cc != null && lc.isNotEmpty && cc.isNotEmpty) {
    Get.updateLocale(Locale(lc, cc));
    return Locale(lc, cc);
  } else {
    Get.updateLocale(Locale('tr', 'TR'));
    return Locale('tr', 'TR');
  }
}

checkLanguage(int lcid) async {
  var language = Languages.GetLngFromLCID(lcid).Code;
  var path = await DbProvider().getDbPath(lngName: language);

  return await File(path).exists();
}

getPhoneId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    // import 'dart:io'
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.id; // unique ID on Android
  }
}
