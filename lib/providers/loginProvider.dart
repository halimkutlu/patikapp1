// ignore_for_file: prefer_final_fields

import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leblebiapp/api/api_repository.dart';
import 'package:leblebiapp/models/http_response.model.dart';
import 'package:leblebiapp/models/user.model.dart';
import 'package:leblebiapp/pages/dashboard.dart';
import 'package:leblebiapp/pages/forgotPassword.dart';
import 'package:leblebiapp/pages/login.dart';
import 'package:leblebiapp/pages/register.dart';
import 'package:leblebiapp/providers/dbprovider.dart';
import 'package:leblebiapp/widgets/customAlertDialog.dart';
import 'package:leblebiapp/widgets/customAlertDialogOnlyOk.dart';
import 'package:provider/provider.dart';

class LoginProvider extends ChangeNotifier {
  final apirepository = APIRepository();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool? _passwordVisible = false;

  bool get passwordVisible => _passwordVisible!;

  TextEditingController get userName => _usernameController;
  TextEditingController get password => _passwordController;

  TextEditingController _forgotMailController = TextEditingController();
  TextEditingController get forgotMailController => _forgotMailController;

  void gotoRegisterPage(BuildContext context) async {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Register()));
  }

  void login(BuildContext context) async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      CustomAlertDialogOnlyConfirm(context, () {
        Navigator.pop(context);
      }, "warning".tr, "userpasswordNotEmpty".tr, ArtSweetAlertType.info,
          "ok".tr);
    } else {
      UserResult apiresult = await apirepository.login(
          userName: _usernameController.text,
          password: _passwordController.text,
          rememberMe: false);

      if (apiresult.success!) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Dashboard()));
      } else {
        CustomAlertDialogOnlyConfirm(context, () {
          Navigator.pop(context);
        }, "warning".tr, apiresult.message.toString(), ArtSweetAlertType.danger,
            "ok".tr);
      }
    }
  }

  void forgotPassword(BuildContext context) {
    if (!forgotMailController.text.isEmail) {
      CustomAlertDialogOnlyConfirm(context, () {
        Navigator.pop(context);
      }, "warning".tr, "userpasswordNotEmpty".tr, ArtSweetAlertType.info,
          "ok".tr);
    } else {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => Login()));
    }
  }

  void gotoForgotPassWordPage(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ForgotPassword()));
  }
}
