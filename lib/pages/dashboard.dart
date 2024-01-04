import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patikmobile/api/static_variables.dart';
import 'package:patikmobile/locale/ChangeLanguage.dart';
import 'package:patikmobile/pages/login.dart';
import 'package:patikmobile/widgets/customAlertDialog.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

bool a = true;

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        CustomAlertDialog(context, () {
          exit(0);
        }, "Uygulamadan çıkmak istiyor musunuz?", "Emin misin?",
            ArtSweetAlertType.info, "ok".tr, "no".tr);
      },
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 208.0),
              child: Center(
                child: Text(
                    "Hoşgeldin ${StaticVariables.Name} ${StaticVariables.Surname}"),
              ),
            ),
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
      ),
    );
  }
}
