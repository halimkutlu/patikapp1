// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/providers/registerProvider.dart';
import 'package:patikmobile/widgets/icon_button.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class MailResponse extends StatefulWidget {
  const MailResponse({super.key});

  @override
  State<MailResponse> createState() => _MailResponseState();
}

class _MailResponseState extends State<MailResponse> {
  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<RegisterProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MainColors.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 20.0.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                  child: Icon(
                Icons.mail_outlined,
                size: 10.h,
              )),
              Padding(
                padding: EdgeInsets.only(top: 4.0.h),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).translate("18"),
                    style: TextStyle(fontSize: 2.5.h),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(2.0.h),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).translate("19"),
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 1.5.h, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomIconButton(
                  textColor: Colors.black,
                  colors: MainColors.primaryColor,
                  //icons: Icon(Icons.arrow_back_ios_new),
                  name: AppLocalizations.of(context).translate("7"),
                  width: 0.3.w,
                  height: 2.5.h,
                  onTap: () {
                    loginProvider.gotoLoginPage(context);
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
