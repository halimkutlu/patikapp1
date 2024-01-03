// ignore_for_file: prefer_final_fields, use_build_context_synchronously, prefer_const_constructors, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/api/api_urls.dart';
import 'package:patikmobile/api/static_variables.dart';
import 'package:patikmobile/locale/ChangeLanguage.dart';
import 'package:patikmobile/models/http_response.model.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/models/user.model.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/pages/forgotPassword.dart';
import 'package:patikmobile/pages/login.dart';
import 'package:patikmobile/pages/register.dart';
import 'package:patikmobile/pages/select_language.dart';
import 'package:patikmobile/pages/select_learn_language.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:patikmobile/providers/download_file.dart';
import 'package:patikmobile/widgets/customAlertDialog.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';

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

  List<dynamic>? _learnLanguage = [];
  List<dynamic> get learnLanguage => _learnLanguage!;

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

  getLearnLanguage(BuildContext context) async {
    _loading = true;
    //_learnLanguage = locale;
    _loading = false;
    //notifyListeners();

    httpSonucModel lngList =
        await apirepository.get(controller: learnLanguageUrl);
    if (lngList.success!) {
      Languages.fromJson(lngList.data);
      notifyListeners();
    } else {
      CustomAlertDialogOnlyConfirm(context, () {
        Navigator.pop(context);
      }, "error".tr, "errorAccured".tr, ArtSweetAlertType.info, "ok".tr);
    }
  }

  setUseLanguage(language, BuildContext context) {
    CustomAlertDialog(context, () {
      changeLanguage(language['locale'], context);
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

  changeLanguage(Locale locale, BuildContext context) {
    updateLanguage(locale);
    Navigator.pop(context);
    CustomAlertDialogOnlyConfirm(context, () {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => SelectLearnLanguage()));
      notifyListeners();
    }, "success".tr, "langSuccess".tr, ArtSweetAlertType.success, "ok".tr);
  }

  Future<FileDownloadStatus> startProcessOfDownloadLearnLanguage(
      String code, BuildContext context, String name, int lcid) async {
    DbProvider dbProvider = DbProvider();
    FileDownloadStatus processResult = FileDownloadStatus();
    processResult.status = false;

    if (code.isNotEmpty) {
      //yükleme ekranı açılır
      _loading = true;
      notifyListeners();

      //DOSYA İNDİRME İŞLEMİ YAPILIR.
      FileDownloadStatus resultDownloadFile =
          await downloadFile("GetLngFileStream", lcid: lcid);

      if (resultDownloadFile.status) {
        //DOSYA İNDRİME İŞLEMİ BAŞARILI İSE DOSYAYI CACHEDEN ALARAK TELEFONA ÇIKARTMA İŞLEMİ YAPILIR
        FileDownloadStatus result = await dbProvider.runProcess(code);
        if (result.status == false) {
          _loading = false;
          notifyListeners();
          processResult.status = false;
          return processResult;
        } else {
          //EĞER DOSYA ÇIKARTMA İŞLEMİ BAŞARILI İSE
          FileDownloadStatus dbresult = await dbProvider.openDbConnection(code);
          if (dbresult.status) {
            processResult.status = true;
          } else {
            processResult.status = false;
          }
          _loading = false;
          notifyListeners();
          return processResult;
        }
      } else {
        processResult.status = false;
        processResult.message = resultDownloadFile.message;
        _loading = false;
        notifyListeners();
        return processResult;
      }
    }
    notifyListeners();
    return processResult;
  }
}
