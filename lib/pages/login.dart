import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leblebiapp/assets/mainColors.dart';
import 'package:leblebiapp/pages/dashboard.dart';
import 'package:leblebiapp/providers/loginProvider.dart';
import 'package:leblebiapp/widgets/custom_textfield.dart';
import 'package:leblebiapp/widgets/icon_button.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);

    return Scaffold(
      body: Column(children: [
        SizedBox(
          height: 15.h,
        ),
        Center(
          child: Text(
            'welcome'.tr,
            style: TextStyle(fontSize: 3.h),
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(top: 4.h, left: 4.h, right: 4.h, bottom: 1.h),
          child: CTextfield(
              controller: TextEditingController(),
              icon: Icons.person_outline,
              name: "userName".tr,
              hintText: "userName".tr),
        ),
        Padding(
          padding: EdgeInsets.only(top: 0.h, left: 4.h, right: 4.h),
          child: CTextfield(
            controller: TextEditingController(),
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
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              child: Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: Text(
                  'forgotPassword'.tr,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
        Center(
          child: Text(
            'or'.tr,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 2.h),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomIconButton(
            textColor: Colors.black,
            colors: Colors.white,
            icons: Icon(Icons.invert_colors),
            name: 'keepWithGoogle'.tr,
            width: 0.3.w,
            height: 2.5.h,
          ),
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'noAccount'.tr + " ",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 1.4.h),
              ),
              InkWell(
                onTap: () {
                  loginProvider.gotoRegisterPage(context);
                },
                child: Text(
                  'register'.tr,
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
                'lib/assets/logo.png',
                width: 600.0,
                height: 240.0,
                fit: BoxFit.cover,
              ),
            ),
          ),
        )
      ]),
    );
  }
}


  //  ElevatedButton(
  //           onPressed: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (context) => const Dashboard()),
  //             );
  //           },
  //           child: Text('dashboard'.tr)),