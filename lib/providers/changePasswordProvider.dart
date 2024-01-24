// ignore_for_file: use_build_context_synchronously, prefer_final_fields

import 'dart:async';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/api/static_variables.dart';
import 'package:patikmobile/models/http_response.model.dart';
import 'package:patikmobile/pages/login.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordProvider extends ChangeNotifier {
  final apirepository = APIRepository();

  TextEditingController _currentPassword = TextEditingController();
  TextEditingController get currentPassword => _currentPassword;

  TextEditingController _newPassword = TextEditingController();
  TextEditingController get newPassword => _newPassword;

  TextEditingController _newPasswordAgain = TextEditingController();
  TextEditingController get newPasswordAgain => _newPasswordAgain;

  //LOADİNG
  bool? _loading = false;
  bool get loading => _loading!;

  initData(BuildContext context) async {}

  void changePassword(BuildContext context) async {
    if (_currentPassword.text.isEmpty ||
        _newPassword.text.isEmpty ||
        _newPasswordAgain.text.isEmpty) {
      CustomAlertDialogOnlyConfirm(context, () {
        Navigator.pop(context);
      }, "warning".tr, "changePasswordNotEmpty".tr, ArtSweetAlertType.info,
          "ok".tr);
    } else if (_newPassword.text != _newPasswordAgain.text) {
      CustomAlertDialogOnlyConfirm(context, () {
        Navigator.pop(context);
      }, "warning".tr, "notSameWithNewPassword".tr, ArtSweetAlertType.info,
          "ok".tr);
    } else {
      _loading = true;
      httpSonucModel apiresult = await apirepository.post();

      if (apiresult.success!) {
      } else {
        CustomAlertDialogOnlyConfirm(context, () {
          Navigator.pop(context);
        }, "warning".tr, apiresult.message.toString(), ArtSweetAlertType.danger,
            "ok".tr);
      }
    }

    _loading = false;
    notifyListeners();
  }
}
