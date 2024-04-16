// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  SharedPreferences? _prefs;
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    _prefs ??= await SharedPreferences.getInstance();

    if (state == AppLifecycleState.resumed) {
      startTimer();
    } else if (state == AppLifecycleState.paused) {
      stopTimer();
    }
  }

  void startTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedTime = prefs.getInt("app_duration");

    stopwatch.start();
    timer = Timer.periodic(Duration(minutes: 1), (timer) {
      // print("Geçen süre: " + stopwatch.elapsed.inMinutes.toString());
      // print("Kayıt edilen zaman" + savedTime.toString());
      if (savedTime != null) {
        prefs.setInt("app_duration", stopwatch.elapsed.inMinutes + savedTime);
      } else {
        prefs.setInt("app_duration", stopwatch.elapsed.inMinutes);
      }
    });
  }

  void stopTimer() async {
    stopwatch.stop();
    timer?.cancel();
    // prefs.setInt("app_duration", stopwatch.elapsed.inMinutes);
  }
}
