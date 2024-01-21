import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/providers/registerProvider.dart';
import 'package:patikmobile/widgets/custom_textfield.dart';
import 'package:patikmobile/widgets/icon_button.dart';
import 'package:patikmobile/widgets/loading_bar.dart';
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
      appBar: !loginProvider.loading
          ? AppBar(
              backgroundColor: MainColors.backgroundColor,
            )
          : null,
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: 15.h,
          ),
          Center(
            child: Text(
              AppLocalizations.of(context).translate("15"),
              style: TextStyle(fontSize: 3.h),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(top: 4.h, left: 4.h, right: 4.h, bottom: 1.h),
            child: CTextfield(
                controller: loginProvider.userName,
                icon: Icons.person_outline,
                name: AppLocalizations.of(context).translate("9"),
                hintText: AppLocalizations.of(context).translate("9",
                    addRight: AppLocalizations.of(context)
                        .translate("16", addLeft: " (", addRight: ")"))),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.h, left: 4.h, right: 4.h),
            child: CTextfield(
              controller: loginProvider.password,
              obscureText: true,
              name: AppLocalizations.of(context).translate("10"),
              hintText: AppLocalizations.of(context).translate("10"),
              icon: Icons.lock_outline,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.h, left: 4.h, right: 4.h),
            child: CTextfield(
              controller: loginProvider.firstName,
              name: "Ad",
              hintText: "Ad",
              icon: Icons.contact_page_outlined,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.h, left: 4.h, right: 4.h),
            child: CTextfield(
              controller: loginProvider.lastName,
              name: "Soyad",
              hintText: "Soyad",
              icon: Icons.contact_page_outlined,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomIconButton(
              textColor: Colors.black,
              colors: MainColors.primaryColor,
              icons: Icon(Icons.send),
              name: AppLocalizations.of(context).translate("15"),
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
                  AppLocalizations.of(context).translate("17", addRight: " "),
                  style:
                      TextStyle(fontWeight: FontWeight.w500, fontSize: 1.4.h),
                ),
                InkWell(
                  onTap: () {
                    loginProvider.gotoLoginPage(context);
                  },
                  child: Text(
                    AppLocalizations.of(context).translate("7"),
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 1.4.h,
                        color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          Container(child: loginProvider.loading ? Loading() : Container())
        ]),
      ),
    );
  }
}
