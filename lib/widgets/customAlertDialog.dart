import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:patikmobile/assets/mainColors.dart';

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
