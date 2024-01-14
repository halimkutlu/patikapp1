// ignore_for_file: prefer_final_fields, use_build_context_synchronously, prefer_const_constructors, prefer_interpolation_to_compose_strings, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:io';

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
import 'package:patikmobile/pages/survey.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:patikmobile/providers/download_file.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:patikmobile/widgets/customAlertDialog.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider extends ChangeNotifier {
  final apirepository = APIRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

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

  void logout(BuildContext context) async {
    CustomAlertDialog(context, () {
      apirepository.removeToken();
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => Login()));
    }, "logout".tr, "logoutMessage".tr, ArtSweetAlertType.question, "yes".tr,
        "no".tr);
  }

  void login(BuildContext context) async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      CustomAlertDialogOnlyConfirm(context, () {
        Navigator.pop(context);
      }, "warning".tr, "userpasswordNotEmpty".tr, ArtSweetAlertType.info,
          "ok".tr);
    } else {
      _loading = true;
      print("login provider girdi.");
      notifyListeners();
      print("login provider girdi. : işlem başlıyor");

      UserResult apiresult = await apirepository.login(
          userName: _usernameController.text,
          password: _passwordController.text,
          rememberMe: false);

      if (apiresult.success!) {
        //dil kontrolü
        if (StorageProvider.learnLanguge != null &&
            StorageProvider.learnLanguge!.LCID > 0) {
          DbProvider dbProvider = DbProvider();
          bool isLanguageExist = await dbProvider
              .checkLanguage(StorageProvider.learnLanguge!.LCID);

          if (isLanguageExist)
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const Dashboard(0)));
          else
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SelectLearnLanguage()));
        } else {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => SelectLanguage()));
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

  void LoginWithGoogle(BuildContext context) async {
    try {
      _loading = true;
      notifyListeners();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user == null || user.uid.isEmpty || user.email!.isEmpty) {
        CustomAlertDialogOnlyConfirm(context, () {
          Navigator.pop(context);
        }, "warning".tr, "userpasswordNotEmpty".tr, ArtSweetAlertType.info,
            "ok".tr);

        return;
      }

      UserResult apiresult = await apirepository.login(
          userName: user.email,
          password: user.uid,
          rememberMe: false,
          Uid: user.uid,
          Name: user.displayName);

      if (apiresult.success!) {
        if (StaticVariables.FirstTimeLogin) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => SelectLanguage()));
        } else {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const Dashboard(0)));
        }
      } else {
        CustomAlertDialogOnlyConfirm(context, () {
          Navigator.pop(context);
        }, "warning".tr, apiresult.message.toString(), ArtSweetAlertType.danger,
            "ok".tr);
      }
      _loading = false;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  void forgotPassword(BuildContext context) async {
    if (!forgotMailController.text.isEmail) {
      CustomAlertDialogOnlyConfirm(context, () {
        Navigator.pop(context);
      }, "warning".tr, "userpasswordNotEmpty".tr, ArtSweetAlertType.info,
          "ok".tr);
    } else {
      _loading = true;
      notifyListeners();
      httpSonucModel apiresult = await apirepository.post(
          controller: forgotPasswordUrl,
          data: {"Username": forgotMailController.text});
      if (apiresult.success!) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => Login()));
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

  void gotoForgotPassWordPage(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ForgotPassword()));
  }

  getLearnLanguage(BuildContext context) async {
    httpSonucModel lngList =
        await apirepository.get(controller: learnLanguageUrl);
    if (lngList.success!) {
      Languages.fromJson(lngList.data);
      notifyListeners();
    }
    // else {
    //   CustomAlertDialogOnlyConfirm(context, () {
    //     Navigator.pop(context);
    //   }, "error".tr, "errorAccured".tr, ArtSweetAlertType.info, "ok".tr);
    // }
  }

  setUseLanguage(Lcid language, BuildContext context, bool dashboard) {
    CustomAlertDialog(context, () {
      changeLanguage(language, context, dashboard);
    },
        "areYouSure".tr,
        "applicationLanguage".tr +
            " " +
            language.Name! +
            " " +
            "applicationLanguage2".tr,
        ArtSweetAlertType.question,
        "yes".tr,
        "no".tr);
  }

  changeLanguage(Lcid locale, BuildContext context, bool dashboard) {
    StorageProvider.updateLanguage(context, locale);
    notifyListeners();
    Navigator.pop(context);
    CustomAlertDialogOnlyConfirm(context, () {
      if (dashboard) {
        Navigator.pop(context);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Dashboard(0)));
      } else {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => SelectLearnLanguage()));
      }

      notifyListeners();
    }, "success".tr, "langSuccess".tr, ArtSweetAlertType.success, "ok".tr);
  }

  Future<FileDownloadStatus> startProcessOfDownloadLearnLanguage(
      Lcid lcid, void Function(int, int)? onReceiveProgress) async {
    DbProvider dbProvider = DbProvider();
    FileDownloadStatus processResult = FileDownloadStatus();
    processResult.status = false;

    if (lcid.Code.isNotEmpty) {
      //yükleme ekranı açılır
      //_loading = true;
      notifyListeners();

      //DOSYA İNDİRME İŞLEMİ YAPILIR.
      FileDownloadStatus resultDownloadFile = await downloadFile(
          "GetLngFileStream",
          lcid: lcid.LCID,
          onReceiveProgress: onReceiveProgress);

      if (resultDownloadFile.status) {
        //DOSYA İNDRİME İŞLEMİ BAŞARILI İSE DOSYAYI CACHEDEN ALARAK TELEFONA ÇIKARTMA İŞLEMİ YAPILIR
        FileDownloadStatus result = await dbProvider.runProcess(lcid.Code);
        if (result.status == false) {
          _loading = false;
          notifyListeners();
          processResult.status = false;
          return processResult;
        } else {
          //EĞER DOSYA ÇIKARTMA İŞLEMİ BAŞARILI İSE

          FileDownloadStatus dbresult = await dbProvider.openDbConnection(lcid);
          if (dbresult.status) {
            processResult.status = true;
          } else {
            processResult.status = false;
          }
          //_loading = false;
          notifyListeners();
          return processResult;
        }
      } else {
        processResult.status = false;
        processResult.message = resultDownloadFile.message;
        //_loading = false;
        notifyListeners();
        return processResult;
      }
    }
    notifyListeners();
    return processResult;
  }
}
