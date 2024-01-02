// ignore_for_file: prefer_final_fields, use_build_context_synchronously

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leblebiapp/api/api_repository.dart';
import 'package:leblebiapp/api/static_variables.dart';
import 'package:leblebiapp/locale/ChangeLanguage.dart';
import 'package:leblebiapp/models/user.model.dart';
import 'package:leblebiapp/pages/dashboard.dart';
import 'package:leblebiapp/pages/forgotPassword.dart';
import 'package:leblebiapp/pages/login.dart';
import 'package:leblebiapp/pages/register.dart';
import 'package:leblebiapp/pages/select_language.dart';
import 'package:leblebiapp/widgets/customAlertDialog.dart';
import 'package:leblebiapp/widgets/customAlertDialogOnlyOk.dart';

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

  //LOADİNG
  bool? _loading = false;
  bool get loading => _loading!;

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
      _loading = true;
      notifyListeners();
      UserResult apiresult = await apirepository.login(
          userName: _usernameController.text,
          password: _passwordController.text,
          rememberMe: false);

      if (apiresult.success!) {
        if (StaticVariables.FirstTimeLogin) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => SelectLanguage()));
        } else {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const Dashboard()));
        }
      } else {
        CustomAlertDialogOnlyConfirm(context, () {
          Navigator.pop(context);
        }, "warning".tr, apiresult.message.toString(), ArtSweetAlertType.danger,
            "ok".tr);
      }
      _loading = false;
      notifyListeners();
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

  getUseLanguage() {
    return locale;
  }

  setUseLanguage(language, BuildContext context) {
    CustomAlertDialog(context, () {
      changeLanguage(language['locale']);
    },
        "areYouSure".tr,
        "applicationLanguage".tr +
            " " +
            language['name'] +
            " " +
            "applicationLanguage2".tr,
        ArtSweetAlertType.question,
        "yes".tr,
        "no".tr);
  }

  changeLanguage(Locale locale) {
    updateLanguage(locale);
    notifyListeners();
  }
}
