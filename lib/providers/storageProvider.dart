// ignore_for_file: file_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patikmobile/api/static_variables.dart';
import 'package:patikmobile/locale/app_localization_delegate.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/models/user_roles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageProvider {
  static String appLcidKey = "applcid";
  static String learnLcidKey = "learnlcid";
  static Lcid? appLanguge;
  static Lcid? learnLanguge;
  static String? learnLanguageDir;
  static String? appDir;

  static load() async {
    var dir = await getApplicationDocumentsDirectory();
    appDir = dir.path;
    await StorageProvider.getAppLanguage();
    await StorageProvider.getLearnLanguage();
  }

  static getAppLanguage() async {
    SharedPreferences shrdp = await SharedPreferences.getInstance();
    StaticVariables.token = shrdp.getString("Token") ?? "";
    if (StorageProvider.appLanguge == null) {
      int applcid = 0;

      applcid = shrdp.getInt(StorageProvider.appLcidKey) ?? 0;
      if (applcid == 0) {
        applcid = 1033;
        await shrdp.setInt(StorageProvider.appLcidKey, applcid);
      }
      StorageProvider.appLanguge = Languages.GetLngFromLCID(applcid);
      await shrdp.setString(
          "AppLanguageName", StorageProvider.appLanguge!.Name!);
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
    learnLanguageDir = "$appDir/${StorageProvider.learnLanguge?.Code}";
    return StorageProvider.learnLanguge;
  }

  static updateLanguage(BuildContext context, Lcid locale) async {
    SharedPreferences shrdp = await SharedPreferences.getInstance();
    StorageProvider.appLanguge = locale;
    await shrdp.setInt(appLcidKey, locale.LCID);
    await shrdp.setString("AppLanguageName", locale.Name!);
    AppLocalizationsDelegate().load(const Locale('en'));
  }

  static updateLearnLanguage(BuildContext context, Lcid locale) async {
    SharedPreferences shrdp = await SharedPreferences.getInstance();
    StorageProvider.learnLanguge = locale;
    await shrdp.setInt(learnLcidKey, locale.LCID);
    await shrdp.setString("LearnLanguageName", locale.Name!);
  }

  static int getPrimaryRole(dynamic userRoles) {
    if (userRoles.contains(UserRole.admin)) {
      return UserRole.admin;
    } else if (userRoles.contains(UserRole.premium)) {
      return UserRole.premium;
    } else if (userRoles.contains(UserRole.qr)) {
      return UserRole.qr;
    } else if (userRoles.contains(UserRole.free)) {
      return UserRole.free;
    } else {
      return UserRole
          .unknown; // Varsayılan olarak unknown ya da istediğiniz başka bir değer
    }
  }
}
