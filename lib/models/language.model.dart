// ignore_for_file: non_constant_identifier_names, avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:patikmobile/locale/app_localizations.dart';

extension StringExtension on String {
  String trReplace() => replaceAll("İ", "I")
      .replaceAll("Ç", "C")
      .replaceAll("Ö", "O")
      .replaceAll("Ş", "S")
      .replaceAll("Ğ", "G")
      .replaceAll("Ü", "U");
}

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
    Lcid(Code: "ar-EG", LCID: 3073, Name: "Arabic"),
    Lcid(Code: "hy-AM", LCID: 1067, Name: "Armenian_East"),
    //Lcid(Code: "hy-AW", LCID: 99997, Name: "Armenian_West"),
    Lcid(Code: "bs-Latn-BA", LCID: 5146, Name: "Bosnian"),
    Lcid(Code: "pt-BR", LCID: 1046, Name: "Brazil"),
    Lcid(Code: "bg-BG", LCID: 1026, Name: "Bulgarian"),
    Lcid(Code: "zh-CN", LCID: 2052, Name: "Chinese"),
    Lcid(Code: "nl-NL", LCID: 1043, Name: "Dutch"),
    Lcid(Code: "en-US", LCID: 1033, Name: "English"),
    Lcid(Code: "fr-FR", LCID: 1036, Name: "French"),
    Lcid(Code: "ka-GE", LCID: 1079, Name: "Georgian"),
    Lcid(Code: "de-DE", LCID: 1031, Name: "German"),
    Lcid(Code: "el-GR", LCID: 1032, Name: "Greek"),
    Lcid(Code: "it-IT", LCID: 1040, Name: "Italian"),
    Lcid(Code: "ja-JP", LCID: 1041, Name: "Japanese"),
    Lcid(Code: "ko-KR", LCID: 1042, Name: "Korean"),
    //Lcid(Code: "tr-KU", LCID: 99998, Name: "Kurdish"),
    //Lcid(Code: "tr-LZ", LCID: 99999, Name: "Lazuri"),
    Lcid(Code: "mk-MK", LCID: 1071, Name: "Macedonian"),
    Lcid(Code: "fa-IR", LCID: 1065, Name: "Persian"),
    Lcid(Code: "pl-PL", LCID: 1045, Name: "Polish"),
    Lcid(Code: "pt-PT", LCID: 2070, Name: "Portuguese"),
    Lcid(Code: "ru-RU", LCID: 1049, Name: "Russian"),
    Lcid(Code: "es-ES", LCID: 3082, Name: "Spanish"),
    Lcid(Code: "tr-TR", LCID: 1055, Name: "Turkish")
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

  static LoadLngList(BuildContext context) {
    LngList.forEach((element) {
      element.Name = AppLocalizations.of(context).translateLngName(element);
    });
    LngList.sort((a, b) => a.Name!.trReplace().compareTo(b.Name!.trReplace()));
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
