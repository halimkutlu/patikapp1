// ignore_for_file: use_build_context_synchronously, prefer_final_fields, file_names

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/models/http_response.model.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';

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
      },
          AppLocalizations.of(context).translate("164"),
          AppLocalizations.of(context).translate("169"),
          ArtSweetAlertType.info,
          AppLocalizations.of(context).translate("159"));
    } else if (_newPassword.text != _newPasswordAgain.text) {
      CustomAlertDialogOnlyConfirm(context, () {
        Navigator.pop(context);
      },
          AppLocalizations.of(context).translate("164"),
          AppLocalizations.of(context).translate("170"),
          ArtSweetAlertType.info,
          AppLocalizations.of(context).translate("159"));
    } else {
      _loading = true;
      httpSonucModel apiresult = await apirepository.post();

      if (apiresult.success!) {
      } else {
        CustomAlertDialogOnlyConfirm(context, () {
          Navigator.pop(context);
        },
            AppLocalizations.of(context).translate("164"),
            apiresult.message.toString(),
            ArtSweetAlertType.danger,
            AppLocalizations.of(context).translate("159"));
      }
    }

    _loading = false;
    notifyListeners();
  }
}
