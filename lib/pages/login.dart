// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/providers/loginProvider.dart';
import 'package:patikmobile/widgets/custom_textfield.dart';
import 'package:patikmobile/widgets/icon_button.dart';
import 'package:patikmobile/widgets/loading_bar.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late LoginProvider loginProvider;
  @override
  void initState() {
    super.initState();
  }

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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(children: [
              SizedBox(
                height: 15.h,
              ),
              Center(
                child: Text(
                  AppLocalizations.of(context).translate("8"),
                  style: TextStyle(fontSize: 3.h),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: 4.h, left: 4.h, right: 4.h, bottom: 1.h),
                child: CTextfield(
                    controller: loginProvider.userName,
                    icon: Icons.person_outline,
                    name: AppLocalizations.of(context).translate("9"),
                    hintText: AppLocalizations.of(context).translate("9")),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.h, left: 4.h, right: 4.h),
                child: CTextfield(
                  obscureText: true,
                  controller: loginProvider.password,
                  name: AppLocalizations.of(context).translate("10"),
                  hintText: AppLocalizations.of(context).translate("10"),
                  icon: Icons.lock_outline,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomIconButton(
                  textColor: Colors.black,
                  colors: MainColors.primaryColor,
                  icons: Icon(Icons.send),
                  name: AppLocalizations.of(context).translate("7"),
                  width: 0.283.w,
                  height: 3.2.h,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    loginProvider.login(context);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      loginProvider.gotoForgotPassWordPage(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 10.w),
                      child: Text(
                        AppLocalizations.of(context).translate("11"),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
              Center(
                child: Text(
                  AppLocalizations.of(context).translate("12"),
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 2.h),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomIconButton(
                  textColor: Colors.black,
                  colors: Colors.white,
                  icons: Icon(Icons.invert_colors),
                  name: AppLocalizations.of(context).translate("13"),
                  width: 0.3.w,
                  height: 3.4.h,
                  onTap: () {
                    loginProvider.LoginWithGoogle(context);
                  },
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)
                          .translate("14", addRight: " "),
                      style: TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 1.4.h),
                    ),
                    InkWell(
                      onTap: () {
                        loginProvider.gotoRegisterPage(context);
                      },
                      child: Text(
                        AppLocalizations.of(context).translate("15"),
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 1.4.h,
                            color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 5.h),
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
            ]),
          ),
          Positioned(child: Loading())
        ],
      ),
    );
  }
}
