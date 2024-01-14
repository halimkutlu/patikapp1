// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/pages/learn_page.dart';
import 'package:patikmobile/providers/mainPageProvider.dart';
import 'package:patikmobile/services/appTimer.dart';
import 'package:patikmobile/widgets/icon_button.dart';
import 'package:patikmobile/widgets/icon_list_item.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Timer? _timer;
  AppLifecycleObserver? _lifecycleObserver;
  late MainPageProvider mainProvider;
  int appMinute = 0;

  @override
  void initState() {
    super.initState();
    _lifecycleObserver = AppLifecycleObserver();
    _lifecycleObserver!.startTimer();
    WidgetsBinding.instance.addObserver(_lifecycleObserver!);
    getMinute();
    mainProvider = Provider.of<MainPageProvider>(context, listen: false);
    mainProvider.init();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      getMinute();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Center(
          child: Text(
            "Hemen Başla!",
            style: TextStyle(fontSize: 4.h, fontWeight: FontWeight.bold),
          ),
        ),
        Column(
          children: [
            IconListItem(
                Text: "Yeni Kelimeler Öğren",
                imageStr: 'lib/assets/img/graduate.png',
                onTap: () {}),
            IconListItem(
                Text: "Antrenman Yap",
                imageStr: 'lib/assets/img/muscle.png',
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Dashboard(1)));
                }),
            IconListItem(
              Text: "Diyaloglar",
              imageStr: 'lib/assets/img/chat.png',
              onTap: () => mainProvider.changePage(3),
            ),
            statusArea(),
            brandArea(),
            boxArea()
          ],
        )
      ]),
    );
  }

  Widget statusArea() {
    return Padding(
      padding: EdgeInsets.only(top: 1.0.h, bottom: 2.h),
      child: Column(
        children: [
          Text(
            "Harika!",
            style: TextStyle(fontSize: 2.5.h),
          ),
          Text(
            "Çok iyi ilerliyorsun.",
            style: TextStyle(fontSize: 2.5.h),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Uygulamada toplam ",
                style: TextStyle(fontSize: 2.0.h, fontWeight: FontWeight.bold),
              ),
              Text(
                appMinute.toString(),
                style: TextStyle(
                    fontSize: 3.0.h,
                    color: Colors.red,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                " dakika zaman geçirdin",
                style: TextStyle(fontSize: 2.0.h, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Bu sürede ",
                style: TextStyle(fontSize: 2.0.h, fontWeight: FontWeight.bold),
              ),
              Text(
                mainProvider.getLernedWordCount.toString(),
                style: TextStyle(
                    fontSize: 3.0.h,
                    color: Colors.red,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                " kelime öğrendin",
                style: TextStyle(fontSize: 2.0.h, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget brandArea() {
    return Padding(
      padding: EdgeInsets.only(left: 3.w, right: 3.w),
      child: Container(
        height: 21.h,
        decoration: BoxDecoration(color: MainColors.primaryColor),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/img/bicyle.png',
                width: 9.w,
                height: 4.h,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Patik",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 4.h),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(
                'lib/assets/img/twitter.png',
                width: 9.w,
                height: 4.h,
                fit: BoxFit.cover,
              ),
              Image.asset(
                'lib/assets/img/facebook.png',
                width: 9.w,
                height: 4.h,
                fit: BoxFit.cover,
              ),
              Text(
                "Hoşuna gitti mi?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 2.h),
              ),
              Image.asset(
                'lib/assets/img/instagram.png',
                width: 9.w,
                height: 4.h,
                fit: BoxFit.cover,
              ),
              Image.asset(
                'lib/assets/img/whatsapp.png',
                width: 9.w,
                height: 4.h,
                fit: BoxFit.cover,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomIconButton(
              textColor: Colors.white,
              colors: Colors.red,
              icons: Icon(Icons.send),
              name: "Arkadaşlarına tavsiye et",
              width: 0.3.w,
              height: 2.5.h,
              onTap: () {},
            ),
          ),
        ]),
      ),
    );
  }

  Widget boxArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          box(
            "Öğrendim",
            MainColors.boxColor1,
            mainProvider.getLernedWordCount.toString(),
            'lib/assets/img/ilearned.png',
          ),
          box(
            "Tekrar et",
            MainColors.boxColor2,
            mainProvider.getRepeatedWordCount.toString(),
            'lib/assets/img/repeat.png',
          ),
          box(
            "Sıkı çalış",
            MainColors.boxColor3,
            mainProvider.getWorkHardCount.toString(),
            'lib/assets/img/sun.png',
          ),
        ],
      ),
    );
  }

  Widget box(String text, Color color, String value, String iconUrl) {
    return Column(
      children: [
        Container(
          height: 3.h,
          width: 25.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(3),
                  bottomRight: Radius.circular(3)),
              color: color,
              border: Border.all(width: 3, color: Colors.black38)),
          child: Center(
              child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
        ),
        Container(
          height: 8.h,
          width: 23.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              color: color,
              border: Border.all(width: 3, color: Colors.black38)),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0.1.h),
                child: Image.asset(
                  iconUrl,
                  width: 6.w,
                  height: 3.h,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.5.h, right: 2.w, left: 2.w),
                child: Container(
                  color: Colors.white,
                  child: Center(
                      child: Text(
                    value,
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 2.2.h),
                  )),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<int> _getStoredTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int time = prefs.getInt("app_duration") ?? 0;
    return time;
  }

  void getMinute() async {
    appMinute = await _getStoredTime();
    if (mounted) {
      setState(() {});
    }
  }
}
