import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:leblebiapp/assets/mainColors.dart';
import 'package:leblebiapp/providers/registerProvider.dart';
import 'package:leblebiapp/widgets/icon_button.dart';
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
                    "Mail kutunuzu kontrol ediniz",
                    style: TextStyle(fontSize: 2.5.h),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 2.0.h),
                child: Center(
                  child: Text(
                    "Size bir e-mail gönderdik. Lütfen e-mail adresinizi girin.",
                    style:
                        TextStyle(fontSize: 1.5.h, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Gelen maildeki linke tıklayarak işleminizi tamamlayabilirsiniz.",
                  style:
                      TextStyle(fontSize: 1.5.h, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomIconButton(
                  textColor: Colors.black,
                  colors: MainColors.primaryColor,
                  icons: Icon(Icons.arrow_back_ios_new),
                  name: 'backToLogin'.tr,
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
