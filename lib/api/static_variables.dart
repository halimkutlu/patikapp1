//uygulama içerisinde kullanılacak bilgiler için model oluşturulması.
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
}
