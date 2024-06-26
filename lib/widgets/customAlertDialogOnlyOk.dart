// ignore_for_file: non_constant_identifier_names, file_names

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:patikmobile/assets/style/mainColors.dart';

CustomAlertDialogOnlyConfirm(
  BuildContext context,
  VoidCallback? onConfirm,
  String title,
  String text,
  ArtSweetAlertType type,
  String confirmButtonText,
) {
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
          onConfirm: onConfirm));
}
