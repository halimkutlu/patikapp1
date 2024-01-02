// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leblebiapp/providers/loginProvider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class SelectLanguage extends StatefulWidget {
  const SelectLanguage({super.key});

  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 10.h, left: 10.w, right: 10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 30.w,
                height: 5.h,
                margin: EdgeInsets.only(bottom: 2.h),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 0.50, color: Color(0xFF7E7B7B)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Image.asset(
                            'lib/assets/user_language.png',
                            fit: BoxFit.cover,
                            height: 2.3.h,
                          ),
                        ),
                        Text(
                          "chooseUserLanguage".tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF0F1011),
                            fontSize: 2.h,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            height: 0.06,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              for (var language in loginProvider.getUseLanguage())
                InkWell(
                  onTap: () {
                    loginProvider.setUseLanguage(language, context);
                  },
                  child: Container(
                    width: 30.w,
                    height: 5.h,
                    margin: EdgeInsets.only(bottom: 2.h),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 0.50, color: Color(0xFF7E7B7B)),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          language['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF0F1011),
                            fontSize: 2.h,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            height: 0.06,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 5.h),
                  child: Container(
                    width: 90,
                    height: 90,
                    child: Image.asset(
                      'lib/assets/logo.png',
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
