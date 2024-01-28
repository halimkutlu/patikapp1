// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, use_build_context_synchronously

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:patikmobile/providers/loginProvider.dart';
import 'package:patikmobile/widgets/customAlertDialog.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class SelectLanguage extends StatefulWidget {
  final bool? dashboard;
  const SelectLanguage({super.key, this.dashboard = false});

  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  late LoginProvider loginProvider;
  late double received = 0;
  late bool isDownloading = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onReceiveProgress(int received_, int total_) {
    setState(() {
      received = received_ / total_;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    final appDbProvider = Provider.of<AppDbProvider>(context);
    //late NavigatorState _navigator;
    return Scaffold(
      body: Stack(children: [
        if (isDownloading) ...[
          Center(
              child: CircularPercentIndicator(
                  radius: 100,
                  lineWidth: 35,
                  percent: received.toPrecision(2),
                  center: Text(
                    "${(received * 100).round()}%",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  footer: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Downloading Files',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.green,
                  backgroundColor: Colors.redAccent))
        ] else ...[
          Padding(
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
                        onTap: () async {
                          var lngCheck =
                              await appDbProvider.checkLanguage(language.LCID);
                          if (lngCheck) {
                            loginProvider.setUseLanguage(
                                language, context, widget.dashboard ?? false);

                            await appDbProvider.closeDbConnection();
                            await appDbProvider.openDbConnection(language);
                            if (widget.dashboard == true) {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => Dashboard(0)),
                                  (Route<dynamic> route) => false);
                            } else {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => Dashboard(0)));
                            }
                          } else {
                            CustomAlertDialog(context, () async {
                              Navigator.pop(context);
                              isDownloading = true;

                              FileDownloadStatus status = await loginProvider
                                  .startProcessOfDownloadLearnLanguage(
                                      language, onReceiveProgress);
                              if (status.status) {
                                if (widget.dashboard == true) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => Dashboard(0)),
                                      (Route<dynamic> route) => false);
                                } else {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) => Dashboard(0)));
                                }
                              } else {
                                CustomAlertDialogOnlyConfirm(context, () {
                                  Navigator.pop(context);
                                }, "error".tr, status.message,
                                    ArtSweetAlertType.danger, "ok".tr);
                              }

                              isDownloading = false;
                            },
                                "areYouSure".tr,
                                "${AppLocalizations.of(context).translateLngName(language)} ${"choosenLearnLanguage".tr}",
                                ArtSweetAlertType.question,
                                "ok".tr,
                                "no".tr);
                          }
                        },
                        child: Container(
                          width: 30.w,
                          height: 5.h,
                          margin: EdgeInsets.only(bottom: 2.h),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 0.50, color: Color(0xFF7E7B7B)),
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
        ]
      ]),
    );
  }
}
