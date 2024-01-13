
// import 'dart:convert';
// import 'dart:io';
// import 'dart:ui';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:get/get.dart';
// import 'package:patikmobile/api/static_variables.dart';
// import 'package:patikmobile/models/language.model.dart';
// import 'package:patikmobile/providers/dbprovider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// updateLanguage(Lcid locale) async {
//   //Get.updateLocale(locale);
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   prefs.setInt("applcid", locale.LCID);
//   // prefs.setString("language_code", locale.languageCode);
//   // prefs.setString("countryCode", locale.countryCode!);
//   // prefs.setString("language_name", name);

//   // Sayfayı yeniden oluşturarak getLanguage fonksiyonunu tekrar çağır
//   // Get.back();
// }

// getLanguage() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   var lc = prefs.getInt("applcid");
//   if (lc != null) {
//     return Languages.GetCodeFromLCID(lc);
//   } else {
//     return Languages.GetLngFromCode("en-US");
//   }
// }



// String getPhoneId() {
//   if (StaticVariables.PhoneID.isEmpty) {
//     var deviceInfo = DeviceInfoPlugin();
//     if (Platform.isIOS) {
//       // import 'dart:io'
//       deviceInfo.iosInfo.then(
//           (value) => StaticVariables.PhoneID = value.identifierForVendor!);
//     } else if (Platform.isAndroid) {
//       deviceInfo.androidInfo
//           .then((value) => StaticVariables.PhoneID = value.id);
//     }
//   }
//   return StaticVariables.PhoneID;
// }
