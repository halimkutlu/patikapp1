import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:patikmobile/assets/mainColors.dart';
import 'package:patikmobile/providers/loginProvider.dart';
import 'package:patikmobile/providers/registerProvider.dart';
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
                  'forgotPassword'.tr,
                  style: TextStyle(fontSize: 3.h),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4.0.h, left: 10.w, right: 10.w),
                child: Center(
                  child: Text(
                    "forgotMessage".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 1.7.h),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.h, left: 4.h, right: 4.h),
                child: CTextfield(
                  controller: loginProvider.forgotMailController,
                  name: "mail".tr,
                  hintText: "mail".tr,
                  icon: Icons.lock_outline,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomIconButton(
                  textColor: Colors.black,
                  colors: MainColors.primaryColor,
                  icons: Icon(Icons.send),
                  name: 'send'.tr,
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
