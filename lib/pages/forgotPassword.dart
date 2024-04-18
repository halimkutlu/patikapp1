// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/providers/loginProvider.dart';
import 'package:patikmobile/widgets/custom_textfield.dart';
import 'package:patikmobile/widgets/icon_button.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MainColors.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 5.0.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  AppLocalizations.of(context).translate("11"),
                  style: TextStyle(fontSize: 3.h),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4.0.h, left: 10.w, right: 10.w),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).translate("20"),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 1.7.h),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.h, left: 4.h, right: 4.h),
                child: CTextfield(
                  controller: loginProvider.forgotMailController,
                  name: AppLocalizations.of(context).translate("16"),
                  hintText: AppLocalizations.of(context).translate("16"),
                  icon: Icons.lock_outline,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomIconButton(
                  textColor: Colors.black,
                  colors: MainColors.primaryColor,
                  //icons: Icon(Icons.send),
                  name: AppLocalizations.of(context).translate("21"),
                  width: 0.3.w,
                  height: 2.5.h,
                  onTap: () {
                    loginProvider.forgotPassword(context);
                  },
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Container(
                    width: 90,
                    height: 90,
                    child: Image.asset(
                      'lib/assets/img/logo.png',
                      width: 600.0,
                      height: 240.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
