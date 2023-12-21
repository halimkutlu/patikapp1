import 'dart:ui';

import 'package:get/get.dart';

final List locale = [
  {'name': 'ENGLISH', 'locale': Locale('en', 'US')},
  {'name': 'ಕನ್ನಡ', 'locale': Locale('kn', 'IN')},
  {'name': 'हिंदी', 'locale': Locale('hi', 'IN')},
  {'name': 'Türkçe', 'locale': Locale('tr', 'TR')},
];
updateLanguage(Locale locale) {
  // Get.back();
  Get.updateLocale(locale);
}
