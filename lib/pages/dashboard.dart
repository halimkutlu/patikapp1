import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leblebiapp/locale/ChangeLanguage.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

bool a = true;

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                if (a) {
                  updateLanguage(Locale('tr', 'TR'));
                  a = false;
                } else {
                  updateLanguage(Locale('en', 'US'));
                  a = true;
                }
              },
              child: Text("subscribe".tr))
        ],
      ),
    );
  }
}
