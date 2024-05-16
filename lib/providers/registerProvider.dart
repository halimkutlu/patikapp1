// ignore_for_file: prefer_final_fields, use_build_context_synchronously, file_names, prefer_const_constructors

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/models/http_response.model.dart';
import 'package:patikmobile/pages/login.dart';
import 'package:patikmobile/pages/mailResponse.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';
import 'package:patikmobile/api/api_urls.dart';

class RegisterProvider extends ChangeNotifier {
  final apirepository = APIRepository();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _firstController = TextEditingController();
  TextEditingController _lastController = TextEditingController();

  bool? _passwordVisible = false;

  bool get passwordVisible => _passwordVisible!;

  TextEditingController get userName => _usernameController;
  TextEditingController get password => _passwordController;
  TextEditingController get firstName => _firstController;
  TextEditingController get lastName => _lastController;

  bool? _loading = false;
  bool get loading => _loading!;

  void gotoMailResponsePage(BuildContext context) async {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => MailResponse()));
  }

  void gotoLoginPage(BuildContext context) async {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Login()));
  }

  void register(BuildContext context) async {
    if (_usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _firstController.text.isEmpty ||
        _lastController.text.isEmpty) {
      CustomAlertDialogOnlyConfirm(context, () {
        Navigator.pop(context);
      },
          AppLocalizations.of(context).translate("164"),
          AppLocalizations.of(context).translate("169"),
          ArtSweetAlertType.info,
          AppLocalizations.of(context).translate("159"));
    } else if (!_usernameController.text.isEmail) {
      CustomAlertDialogOnlyConfirm(context, () {
        Navigator.pop(context);
      },
          AppLocalizations.of(context).translate("164"),
          AppLocalizations.of(context).translate("169"),
          ArtSweetAlertType.info,
          AppLocalizations.of(context).translate("159"));
    } else {
      _loading = true;

      httpSonucModel apiresult =
          await apirepository.post(controller: registerUrl, data: {
        "UserName": _usernameController.text,
        "Password": _passwordController.text,
        "FirstName": _firstController.text,
        "LastName": _lastController.text
      });

      if (apiresult.success!) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => MailResponse()));
      } else {
        CustomAlertDialogOnlyConfirm(context, () {
          Navigator.pop(context);
        },
            AppLocalizations.of(context).translate("164"),
            apiresult.message!,
            ArtSweetAlertType.info,
            AppLocalizations.of(context).translate("159"));
      }

      _loading = false;
      notifyListeners();
    }
  }
}
