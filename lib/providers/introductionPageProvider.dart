// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:patikmobile/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroductionPageProvider extends ChangeNotifier {
  bool? _secondPage = false;
  bool get secondPage => _secondPage!;

  initData(BuildContext context) async {}

  nextPage() {
    _secondPage = true;
    notifyListeners();
  }

  set changePage(bool currentIndex) {
    _secondPage = currentIndex;
    notifyListeners();
  }

  skip(BuildContext context) {
    goToLoginPage(context);
  }

  void goToLoginPage(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("introShowed", true);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Login()),
        (Route<dynamic> route) => false);
  }
}
