// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Lcid {
  late String Code;
  late String? Name;
  late int LCID;

  Lcid({required this.LCID, required this.Code, this.Name});

  factory Lcid.fromJson(Map<String, dynamic> json) {
    return Lcid(LCID: json['LCID'], Code: json['Code'], Name: json['Name']);
  }

  Map<String, dynamic> toJson() {
    return {'LCID': LCID, 'Code': Code};
  }
}

class Languages {
  static List<Lcid> LngList = [
    Lcid(Code: "bg-BG", LCID: 1026, Name: "Bulgarian"),
    Lcid(Code: "de-DE", LCID: 1031, Name: "German"),
    Lcid(Code: "el-GR", LCID: 1032, Name: "Greek"),
    Lcid(Code: "en-US", LCID: 1033, Name: "English"),
    Lcid(Code: "fr-FR", LCID: 1036, Name: "French"),
    Lcid(Code: "it-IT", LCID: 1040, Name: "Italian"),
    Lcid(Code: "ja-JP", LCID: 1041, Name: "Japanese"),
    Lcid(Code: "ko-KR", LCID: 1042, Name: "Korean"),
    Lcid(Code: "nl-NL", LCID: 1043, Name: "Dutch"),
    Lcid(Code: "pl-PL", LCID: 1045, Name: "Polish"),
    Lcid(Code: "pt-BR", LCID: 1046, Name: "Brazil"),
    Lcid(Code: "ru-RU", LCID: 1049, Name: "Russian"),
    Lcid(Code: "tr-TR", LCID: 1055, Name: "Turkish"),
    Lcid(Code: "fa-IR", LCID: 1065, Name: "Persian"),
    Lcid(Code: "hy-AM", LCID: 1067, Name: "Armenian_East"),
    Lcid(Code: "mk-MK", LCID: 1071, Name: "Macedonian"),
    Lcid(Code: "ka-GE", LCID: 1079, Name: "Georgian"),
    Lcid(Code: "zh-CN", LCID: 2052, Name: "Chinese"),
    Lcid(Code: "pt-PT", LCID: 2070, Name: "Portuguese"),
    Lcid(Code: "ar-EG", LCID: 3073, Name: "Arabic"),
    Lcid(Code: "es-ES", LCID: 3082, Name: "Spanish"),
    Lcid(Code: "bs-Latn-BA", LCID: 5146, Name: "Bosnian"),
    Lcid(Code: "hy-AW", LCID: 99997, Name: "Armenian_West"),
    Lcid(Code: "tr-KU", LCID: 99998, Name: "Kurdish"),
    Lcid(Code: "tr-LZ", LCID: 99999, Name: "Lazuri")
  ];

  Languages.fromJson(List<dynamic> json) {
    LngList = json
        .map((element) => Lcid(
            LCID: element['LCID'],
            Code: element['Code'],
            Name: element['Name']))
        .toList();

    //setLanguagesToLocalStorage(LngList);
  }

  static Lcid GetLngFromCode(String code) {
    return LngList.firstWhere((element) => element.Code == code);
  }

  // static setLanguagesToLocalStorage(List<Lcid> list) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   // Liste öğelerini JSON formatına çevir
  //   List<String> stringList =
  //       list.map((lcid) => jsonEncode(lcid.toJson())).toList();

  //   prefs.setStringList("languageList", stringList);
  // }

  // static getLanguagesFromLocalStorageWithLCID(int lcid) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   List<String>? stringList = prefs.getStringList("languageList");

  //   if (stringList == null) {
  //     return [];
  //   }

  //   // JSON formatındaki stringleri Lcid nesnelerine çevir
  //   List<Lcid> lcidList =
  //       stringList.map((value) => Lcid.fromJson(jsonDecode(value))).toList();

  //   // LCID'ye göre eşleşen dil kodunu al
  //   return lcidList
  //       .firstWhere((element) => element.LCID == lcid,
  //           orElse: () => Lcid(LCID: 0, Code: ""))
  //       .Code;
  // }

  static Lcid GetLngFromLCID(int lcid) {
    return LngList.firstWhere((element) => element.LCID == lcid);
  }

  static String GetCodeFromLCID(int lcid) {
    return LngList.firstWhere((element) => element.LCID == lcid).Code;
  }

  static int GetLCIDFromCode(String code) {
    return LngList.where((element) => element.Code == code).firstOrNull?.LCID ??
        1033;
  }
}

class FileDownloadStatus {
  String message = "";
  bool status = false;
}
