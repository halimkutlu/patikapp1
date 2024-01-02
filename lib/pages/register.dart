import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patikmobile/assets/mainColors.dart';
import 'package:patikmobile/providers/registerProvider.dart';
import 'package:patikmobile/widgets/custom_textfield.dart';
import 'package:patikmobile/widgets/icon_button.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<RegisterProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: 15.h,
          ),
          Center(
            child: Text(
              'register'.tr,
              style: TextStyle(fontSize: 3.h),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(top: 4.h, left: 4.h, right: 4.h, bottom: 1.h),
            child: CTextfield(
                controller: loginProvider.userName,
                icon: Icons.person_outline,
                name: "userName".tr,
                hintText: "userName".tr),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.h, left: 4.h, right: 4.h),
            child: CTextfield(
              controller: loginProvider.mail,
              name: "mail".tr,
              hintText: "mail".tr,
              icon: Icons.lock_outline,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.h, left: 4.h, right: 4.h),
            child: CTextfield(
              controller: loginProvider.password,
              obscureText: true,
              name: "password".tr,
              hintText: "password".tr,
              icon: Icons.lock_outline,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomIconButton(
              textColor: Colors.black,
              colors: MainColors.primaryColor,
              icons: Icon(Icons.send),
              name: 'login'.tr,
              width: 0.3.w,
              height: 2.5.h,
              onTap: () {
                loginProvider.register(context);
              },
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'noAccount'.tr + " ",
                  style:
                      TextStyle(fontWeight: FontWeight.w500, fontSize: 1.4.h),
                ),
                InkWell(
                  onTap: () {
                    loginProvider.gotoLoginPage(context);
                  },
                  child: Text(
                    'login'.tr,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 1.4.h,
                        color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
