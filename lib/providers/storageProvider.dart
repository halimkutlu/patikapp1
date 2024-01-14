// ignore_for_file: file_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patikmobile/locale/app_localization_delegate.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageProvider {
  static String appLcidKey = "applcid";
  static String learnLcidKey = "learnlcid";
  static Lcid? appLanguge;
  static Lcid? learnLanguge;

  static load() async {
    await StorageProvider.getAppLanguage();
    await StorageProvider.getLearnLanguage();
  }

  static getAppLanguage() async {
    if (StorageProvider.appLanguge == null) {
      int applcid = 0;

      SharedPreferences shrdp = await SharedPreferences.getInstance();

      applcid = shrdp.getInt(StorageProvider.appLcidKey) ?? 0;
      if (applcid == 0) {
        applcid = 1033;
        await shrdp.setInt(StorageProvider.appLcidKey, applcid);
      }
      StorageProvider.appLanguge = Languages.GetLngFromLCID(applcid);
      await shrdp.setString("language_name", StorageProvider.appLanguge!.Name!);
    }
    return StorageProvider.appLanguge!;
  }

  static getLearnLanguage() async {
    if (StorageProvider.learnLanguge == null) {
      int learnlcid = 0;

      SharedPreferences shrdp = await SharedPreferences.getInstance();
      learnlcid = shrdp.getInt(StorageProvider.learnLcidKey) ?? 0;
      if (learnlcid > 0) {
        StorageProvider.learnLanguge = Languages.GetLngFromLCID(learnlcid);
      }
    }
    return StorageProvider.learnLanguge;
  }

  static updateLanguage(BuildContext context, Lcid locale) async {
    SharedPreferences shrdp = await SharedPreferences.getInstance();
    await shrdp.setInt(appLcidKey, locale.LCID);
    await shrdp.setString("language_name", locale.Name!);
    AppLocalizationsDelegate().load(const Locale('en'));
    Get.updateLocale(Locale(locale.Code.split('-').first));
  }
}
