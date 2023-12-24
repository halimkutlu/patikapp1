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
      : data = data['data'],
        success = data['success'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = data;
    data['success'] = success;
    return data;
  }
}
