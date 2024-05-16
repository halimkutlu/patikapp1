// ignore_for_file: non_constant_identifier_names, prefer_const_constructors, file_names

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/pages/dashboard.dart';

CustomAlertDialog(
    BuildContext context,
    VoidCallback? onConfirm,
    String title,
    String text,
    ArtSweetAlertType type,
    String confirmButtonText,
    String denyButtonText) {
  return ArtSweetAlert.show(
      barrierDismissible: false,
      context: context,
      artDialogArgs: ArtDialogArgs(
          cancelButtonColor: Colors.red,
          confirmButtonColor: MainColors.primaryColor,
          type: type,
          title: title,
          text: text,
          confirmButtonText: confirmButtonText,
          denyButtonText: denyButtonText,
          onCancel: () {
            Navigator.pop(context);
          },
          onConfirm: onConfirm));
}

Future<void> askToGoMainMenu(BuildContext context, {VoidCallback? func}) async {
  await CustomAlertDialog(context, () {
    if (func != null) {
      func();
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Dashboard(1)),
        (Route<dynamic> route) => false);
  },
      AppLocalizations.of(context).translate("160"),
      AppLocalizations.of(context).translate("179"),
      ArtSweetAlertType.question,
      AppLocalizations.of(context).translate("159"),
      AppLocalizations.of(context).translate("180"));
}
