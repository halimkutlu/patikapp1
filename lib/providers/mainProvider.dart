// ignore_for_file: prefer_final_fields

import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/models/user_roles.dart';
import 'package:patikmobile/pages/login.dart';
import 'package:patikmobile/pages/mailResponse.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainProvider extends ChangeNotifier {
  final apirepository = APIRepository();

  String? _userName = "";
  String get userName => _userName!;

  String? _nameLastname = "";
  String get nameLastname => _nameLastname!;

  List<UserRole> _userRoles = [];
  List<UserRole> get userRoles => _userRoles;

  String? _roleName = "";
  String get roleName => _roleName!;

  String? _useLanguageName = "";
  String get useLanguageName => _useLanguageName ?? "";

  String? _learnLanguageName = "";
  String get learnLanguageName => _learnLanguageName ?? "";

  int? _roleid = 0;
  int get roleid => _roleid!;
  init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString("userName") ?? "";
    _nameLastname = (prefs.getString("firstName") ?? "") +
        " " +
        (prefs.getString("lastName") ?? "");
    _useLanguageName = prefs.getString("language_name");
    _learnLanguageName = prefs.getString("CurrentLanguageName");
    getRoles(prefs);

    notifyListeners();
  }

  getRoles(SharedPreferences prefs) {
    var rolesString = prefs.getString("roles");
    if (rolesString != null) {
      List<dynamic> rolesList = jsonDecode(rolesString);
      int primaryRole = getPrimaryRole(rolesList);
      _roleid = primaryRole;
      _roleName = getRoleName(primaryRole);
      _userRoles = rolesList.map((role) => UserRole(role)).toList();

      _userRoles.forEach((userRole) {
        print("${userRole.role}: ${userRole.getRoleDescription()}");
      });
    }
  }

  getRolesName(int id) {
    return getRoleName(id);
  }

  int getPrimaryRole(dynamic userRoles) {
    if (userRoles.contains(UserRole.admin)) {
      return UserRole.admin;
    } else if (userRoles.contains(UserRole.premium)) {
      return UserRole.premium;
    } else if (userRoles.contains(UserRole.qr)) {
      return UserRole.qr;
    } else if (userRoles.contains(UserRole.free)) {
      return UserRole.free;
    } else {
      return UserRole
          .unknown; // Varsayılan olarak unknown ya da istediğiniz başka bir değer
    }
  }
}
