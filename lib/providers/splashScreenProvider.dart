// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/pages/introductionPages/introductionPage1.dart';
import 'package:patikmobile/pages/login.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SplashScreenProvider extends ChangeNotifier {
  initData(BuildContext context) async {
    Timer(const Duration(seconds: 3), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var introShowed = prefs.getBool("introShowed");
      if (introShowed != true) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => IntroductionPage1()),
            (Route<dynamic> route) => false);
      } else {
        String? token = prefs.getString("Token");
        String? currentLanguageLCID = prefs.getString("CurrentLanguageLCID");
        List<String>? languageList = prefs.getStringList("languageList");
        if ((token == null) ||
            (currentLanguageLCID == null) ||
            (languageList == null)) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const Login()),
              (Route<dynamic> route) => false);
        } else {
          var language = await Languages.getLanguagesFromLocalStorageWithLCID(
              int.parse(currentLanguageLCID));
          var path = await DbProvider().getDbPath(lngName: language);
          var pathExist = await File(path).exists();
          if (pathExist) {
            var dbProvider = DbProvider();
            FileDownloadStatus status =
                await dbProvider.openDbConnection(language);
            if (status.status) {
              print("Db local storage üzerinden aktif");
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Dashboard()),
                  (Route<dynamic> route) => false);
            }
          } else {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Login()),
                (Route<dynamic> route) => false);
          }
        }
      }
    });

    // var lang = prefs.getString("lang");
  }
}
