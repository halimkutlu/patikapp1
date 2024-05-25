//uygulama içerisinde kullanılacak bilgiler için model oluşturulması.
// ignore_for_file: non_constant_identifier_names, prefer_const_constructors

import 'dart:ui';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:patikmobile/models/user_roles.dart';

class StaticVariables {
  static String token = "";
  static String UserName = "";
  static String Name = "";
  static String Surname = "";
  static List<int> Roles = [];
  static String LangCode = "";
  static bool FirstTimeLogin = true;
  static String PhoneID = "";
  static int lngPlanType = LngPlanType.Free;
  static AdSize adSize = AdSize(width: 0, height: 0);

  StaticVariables.reset() {
    token = "";
    UserName = "";
    Name = "";
    Surname = "";
    Roles = [];
    LangCode = "";
    FirstTimeLogin = true;
    PhoneID = "";
    lngPlanType = LngPlanType.Free;
  }

  static bool _value = false;
  static VoidCallback? _changeHandler;

  static bool get loading => _value;

  static set loading(bool newValue) {
    if (_value != newValue) {
      _value = newValue;
      _notifyChange();
    }
  }

  static setChangeHandler(VoidCallback handler) {
    _changeHandler = handler;
  }

  static _notifyChange() {
    _changeHandler?.call();
  }

  static List<int> ColorList = [
    0xFF1A57FF,
    0xFF22AA00,
    0xFFC70000,
    0xFFFF761A,
  ];

  static Size AppSize = Size(0, 0);
}
