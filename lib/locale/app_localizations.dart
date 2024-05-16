import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:patikmobile/models/language.model.dart';

class AppLocalizations {
  static AppLocalizations? staticAppLocalizations;
  // The locale for which the app is localized
  final Lcid locale;
  // Map to hold the localized strings
  Map<String, String> _localizedStrings = {};

  // Constructor
  AppLocalizations(this.locale);

  // Method to get the current instance of AppLocalizations
  static AppLocalizations of(BuildContext context) {
    try {
      var loc = Localizations.of<AppLocalizations>(context, AppLocalizations) ??
          AppLocalizations(Languages.GetLng());
      if (loc._localizedStrings.isNotEmpty) {
        staticAppLocalizations = loc;
      }
      return loc;
    } catch (e) {
      return staticAppLocalizations!;
    }
  }

  // Method to load the localized strings
  Future<bool> load({String? lng}) async {
    lng ??= locale.Code;
    // Load the localization file from the assets
    String jsonString =
        await rootBundle.loadString('lib/assets/locales/$lng.json');
    // Decode the JSON
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    // Convert the dynamic values to String and store them in the _localizedStrings map
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    Get.updateLocale(Locale(lng.split("-").first));
    // Return true when loading is done
    return true;
  }

  // Method to get a localized string
  String translate(String key, {String? addRight, String? addLeft}) {
    // Return the localized string if it exists, otherwise return a default message
    return (addLeft ?? "") +
        (_localizedStrings[key] ?? 'Key not found') +
        (addRight ?? "");
  }

  String translateLngName(Lcid? lng, {String? addRight, String? addLeft}) {
    // Return the localized string if it exists, otherwise return a default message
    if (lng == null) return "";

    if (!lngTranslateIds.keys.any((element) => element == lng.Code)) return "";

    String key = lngTranslateIds[lng.Code]!;
    return (addLeft ?? "") +
        (_localizedStrings[key] ?? 'Key not found') +
        (addRight ?? "");
  }

  Map<String, String> lngTranslateIds = {
    "bg-BG": "34",
    "de-DE": "29",
    "el-GR": "53",
    "en-US": "41",
    "fr-FR": "38",
    "it-IT": "43",
    "ja-JP": "44",
    "ko-KR": "45",
    "nl-NL": "40",
    "pl-PL": "48",
    "pt-BR": "33",
    "ru-RU": "51",
    "tr-TR": "52",
    "fa-IR": "37",
    "hy-AM": "36",
    "mk-MK": "49",
    "ka-GE": "39",
    "zh-CN": "35",
    "pt-PT": "50",
    "ar-EG": "30",
    "es-ES": "42",
    "bs-Latn-BA": "32",
    "hy-AW": "31",
    "tr-KU": "46",
    "tr-LZ": "47"
  };
}
