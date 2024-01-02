// ignore_for_file: prefer_final_fields

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/pages/login.dart';
import 'package:patikmobile/pages/mailResponse.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';

class RegisterProvider extends ChangeNotifier {
  final apirepository = APIRepository();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _mailController = TextEditingController();

  bool? _passwordVisible = false;

  bool get passwordVisible => _passwordVisible!;

  TextEditingController get userName => _usernameController;
  TextEditingController get password => _passwordController;
  TextEditingController get mail => _mailController;

  void gotoMailResponsePage(BuildContext context) async {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => MailResponse()));
  }

  void gotoLoginPage(BuildContext context) async {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Login()));
  }

  void register(BuildContext context) {
    if (_usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _mailController.text.isEmpty) {
      CustomAlertDialogOnlyConfirm(context, () {
        Navigator.pop(context);
      }, "warning".tr, "userpasswordNotEmpty".tr, ArtSweetAlertType.info,
          "ok".tr);
    } else if (!_mailController.text.isEmail) {
      CustomAlertDialogOnlyConfirm(context, () {
        Navigator.pop(context);
      }, "warning".tr, "userpasswordNotEmpty".tr, ArtSweetAlertType.info,
          "ok".tr);
    } else {
      //TODO API REGİSTER
      if (1 == 1) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => MailResponse()));
      } else {
        //   CustomAlertDialogOnlyConfirm(context, () {
        //   Navigator.pop(context);
        // }, "warning".tr, "userpasswordNotEmpty".tr, ArtSweetAlertType.info,
        //     "ok".tr);
      }
    }
  }
}
