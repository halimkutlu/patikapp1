// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/providers/changePasswordProvider.dart';
import 'package:patikmobile/widgets/custom_textfield.dart';
import 'package:patikmobile/widgets/icon_button.dart';
import 'package:patikmobile/widgets/loading_bar.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  @override
  Widget build(BuildContext context) {
    final cpprovider = Provider.of<ChangePasswordProvider>(context);
    return Scaffold(
      appBar: !cpprovider.loading
          ? AppBar(
              backgroundColor: MainColors.backgroundColor,
            )
          : null,
      body: Stack(
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Column(
              children: [
                Center(
                  child: Text(
                    AppLocalizations.of(context).translate("83"),
                    style: TextStyle(fontSize: 3.h),
                  ),
                ),
                // Center(
                //     child: Text(
                //   "changePasswordDescription".tr,
                //   style: TextStyle(fontSize: 1.5.h),
                // )),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: 0.h, left: 4.h, right: 4.h, bottom: 4.h),
                  child: CTextfield(
                    controller: cpprovider.currentPassword,
                    name: AppLocalizations.of(context).translate("84"),
                    hintText: AppLocalizations.of(context).translate("84"),
                    obscureText: true,
                    icon: Icons.lock_outline,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 0.h, left: 4.h, right: 4.h, bottom: 4.h),
                  child: CTextfield(
                    controller: cpprovider.newPassword,
                    name: AppLocalizations.of(context).translate("85"),
                    obscureText: true,
                    hintText: AppLocalizations.of(context).translate("86"),
                    icon: Icons.lock_outline,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0.h, left: 4.h, right: 4.h),
                  child: CTextfield(
                    controller: cpprovider.newPasswordAgain,
                    name: AppLocalizations.of(context).translate("87"),
                    hintText: AppLocalizations.of(context).translate("87"),
                    obscureText: true,
                    icon: Icons.lock_outline,
                  ),
                ),
              ],
            ),
            CustomIconButton(
              textColor: Colors.black,
              colors: MainColors.primaryColor,
              icons: Icon(Icons.send),
              name: AppLocalizations.of(context).translate("90"),
              width: 0.3.w,
              height: 2.8.h,
              onTap: () {
                cpprovider.changePassword(context);
              },
            ),
          ]),
          Positioned(child: Loading())
        ],
      ),
    );
  }
}
