import 'package:flutter/material.dart';
import 'package:leblebiapp/pages/register.dart';

class LoginProvider extends ChangeNotifier {
  void gotoRegisterPage(BuildContext context) async {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Register()));
  }
}
