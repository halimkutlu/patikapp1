// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_const_constructors, file_names
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/api/static_variables.dart';
import 'package:patikmobile/models/http_response.model.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/pages/introductionPages/introductionPage1.dart';
import 'package:patikmobile/pages/login.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:patikmobile/providers/loginProvider.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenProvider extends ChangeNotifier {
  initData(BuildContext context) async {
    Timer(const Duration(seconds: 3), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var roles = prefs.getString("roles");
      if (roles != null && roles.isNotEmpty) {
        // var roleList = roles.split(',');
        // StaticVariables.Roles = List<int>parse(roles.split(','));
        // Başındaki ve sonundaki köşeli parantezleri kaldır
        String trimmedStr = roles.substring(1, roles.length - 1);

        // Virgülle ayır ve her bir öğeyi int'e dönüştür
        List<int> intList = trimmedStr.split(', ').map(int.parse).toList();
        StaticVariables.Roles = intList;
      }
      var introShowed = prefs.getBool("introShowed");
      if (introShowed != true) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => IntroductionPage1()),
            (Route<dynamic> route) => false);
      } else {
        String? token = prefs.getString("Token");
        int? learningLanguageLCID = prefs.getInt(StorageProvider.learnLcidKey);
        APIRepository apiRepository = APIRepository();
        UserNamePasswordClass userNamePasswordClass =
            await apiRepository.decryptedUserNamePassword();

        if ((token == null || learningLanguageLCID == null) &&
            !userNamePasswordClass.success!) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const Login()),
              (Route<dynamic> route) => false);
        } else {
          // var language = Languages.GetLngFromLCID(learningLanguageLCID!);
          // var path = await DbProvider().getDbPath(lngName: language.Code);

          // var pathExist = await File(path).exists();
          // if (pathExist) {
          //   var dbProvider = DbProvider();
          //   FileDownloadStatus status =
          //       await dbProvider.openDbConnection(language);
          //   if (status.status) {
          //     print("Db local storage üzerinden aktif");
          //     Navigator.of(context).pushAndRemoveUntil(
          //         MaterialPageRoute(builder: (context) => const Dashboard(0)),
          //         (Route<dynamic> route) => false);
          //   }
          // } else {
          //   Navigator.of(context).pushAndRemoveUntil(
          //       MaterialPageRoute(builder: (context) => const Login()),
          //       (Route<dynamic> route) => false);
          // }
          if (userNamePasswordClass.userName!.isEmpty ||
              userNamePasswordClass.Password!.isEmpty) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Login()),
                (Route<dynamic> route) => false);
          } else {
            LoginProvider loginProvider = LoginProvider();

            loginProvider.login(context, userNamePasswordClass.userName,
                userNamePasswordClass.Password, userNamePasswordClass.uid);
          }
        }
      }
    });

    // var lang = prefs.getString("lang");
  }
}
