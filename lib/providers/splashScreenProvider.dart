// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/pages/introductionPages/introductionPage1.dart';
import 'package:patikmobile/pages/login.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenProvider extends ChangeNotifier {
  Widget page = const IntroductionPage1();

  initData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var introShowed = prefs.getBool("introShowed");
    // if (introShowed == true) {
    //   Navigator.of(context).pushAndRemoveUntil(
    //       MaterialPageRoute(builder: (context) => IntroductionPage1()),
    //       (Route<dynamic> route) => false);
    if (introShowed == true) {
      String? token = prefs.getString("Token");
      int? learningLanguageLCID = prefs.getInt(StorageProvider.learnLcidKey);
      if ((token == null) || (learningLanguageLCID == null)) {
        page = const Login();
      } else {
        var language = Languages.GetLngFromLCID(learningLanguageLCID);
        var path = await DbProvider().getDbPath(lngName: language.Code);
        var pathExist = await File(path).exists();
        if (pathExist) {
          var dbProvider = DbProvider();
          FileDownloadStatus status =
              await dbProvider.openDbConnection(language);
          if (status.status) {
            print("Db local storage üzerinden aktif");
            page = const Dashboard(0);
          }
        } else {
          page = const Login();
        }
      }
    }
  }
}
