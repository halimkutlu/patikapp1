// ignore_for_file: camel_case_types, non_constant_identifier_names

//HTTP SONUC MODELİ KULLANILAN SİSTEME GÖRE DEĞİŞTİRİLEBİLİR.
class httpSonucModel {
  dynamic data;
  bool? success;
  String? message;

  httpSonucModel({
    this.data,
    required this.success,
    required this.message,
  });

  httpSonucModel.fromJsonData(Map<String, dynamic> data)
      : data = data['Data'],
        success = data['Success'],
        message = data['Message'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Data'] = data;
    data['Success'] = success;
    data['Message'] = message;
    return data;
  }
}

class UserNamePasswordClass {
  String? userName;
  String? Password;
  String? uid;
  bool? success;

  UserNamePasswordClass({this.userName, this.Password, this.success, this.uid});

  UserNamePasswordClass.fromJsonData(Map<String, dynamic> data)
      : userName = data['userName'],
        Password = data['Password'],
        uid = data['uid'],
        success = data['success'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['userName'] = userName;
    data['Password'] = Password;
    data['success'] = success;
    data['uid'] = uid;
    return data;
  }
}
