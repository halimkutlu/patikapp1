// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/providers/loginProvider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class SelectLanguage extends StatefulWidget {
  final bool? dashboard;
  const SelectLanguage({super.key, this.dashboard = false});

  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
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
      body: Padding(
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
                          'lib/assets/img/user_language.png',
                          fit: BoxFit.cover,
                          height: 2.3.h,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context).translate("27"),
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
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: Languages.LngList.length,
                itemBuilder: (BuildContext context, int index) {
                  var language = Languages.LngList[index];
                  return InkWell(
                    onTap: () {
                      loginProvider.setUseLanguage(
                          language, context, widget.dashboard ?? false);
                    },
                    child: Container(
                      width: 30.w,
                      height: 5.h,
                      margin: EdgeInsets.only(bottom: 2.h),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side:
                              BorderSide(width: 0.50, color: Color(0xFF7E7B7B)),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)
                                .translateLngName(language),
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
                  );
                },
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 5.h, bottom: 3.h),
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
    );
  }
}
