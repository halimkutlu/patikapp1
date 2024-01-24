//uygulama içerisinde kullanılacak bilgiler için model oluşturulması.
import 'dart:ui';

class StaticVariables {
  static String token = "";
  static String UserName = "";
  static String Name = "";
  static String Surname = "";
  static List<int> Roles = [];
  static String LangCode = "";
  static bool FirstTimeLogin = true;
  static String PhoneID = "";

  StaticVariables.reset() {
    token = "";
    UserName = "";
    Name = "";
    Surname = "";
    Roles = [];
    LangCode = "";
    FirstTimeLogin = true;
    PhoneID = "";
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
}
