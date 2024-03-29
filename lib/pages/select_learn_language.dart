// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, use_build_context_synchronously

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:patikmobile/providers/loginProvider.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:patikmobile/widgets/customAlertDialog.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';
import 'package:patikmobile/widgets/loading_bar.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../models/language.model.dart';

class SelectLearnLanguage extends StatefulWidget {
  final bool? noReturn;
  const SelectLearnLanguage({super.key, this.noReturn = false});

  @override
  State<SelectLearnLanguage> createState() => _SelectLearnLanguageState();
}

class _SelectLearnLanguageState extends State<SelectLearnLanguage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late LoginProvider loginProvider;
  late double received = 0;
  late bool isDownloading = false;
  //late NavigatorState _navigator;
  List<dynamic> llanguage = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    //_navigator = Navigator.of(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    //_navigator.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const Dashboard()), (Route<dynamic> route) => false);
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
    final dbProvider = Provider.of<DbProvider>(context);
    if (Languages.LngList.isEmpty) loginProvider.getLearnLanguage(context);

    return Scaffold(
      key: _scaffoldKey,
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
                              'lib/assets/img/learn_language.png',
                              fit: BoxFit.cover,
                              height: 2.3.h,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context).translate("28"),
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
                              await dbProvider.checkLanguage(language.LCID);
                          if (lngCheck) {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString(
                                "CurrentLanguageName", language.Name!);
                            prefs.setInt(
                                StorageProvider.learnLcidKey, language.LCID);
                            await dbProvider.closeDbConnection();
                            await dbProvider.openDbConnection(language);
                            if (widget.noReturn == true) {
                              Navigator.of(_scaffoldKey.currentContext!)
                                  .pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => Dashboard(0)),
                                      (Route<dynamic> route) => false);
                            } else {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => Dashboard(0)));
                            }
                          } else {
                            CustomAlertDialog(_scaffoldKey.currentContext!,
                                () async {
                              Navigator.pop(_scaffoldKey.currentContext!);
                              isDownloading = true;

                              FileDownloadStatus status = await loginProvider
                                  .startProcessOfDownloadLearnLanguage(
                                      language, onReceiveProgress);
                              if (status.status) {
                                if (widget.noReturn == true) {
                                  Navigator.of(_scaffoldKey.currentContext!)
                                      .pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Dashboard(0)),
                                          (Route<dynamic> route) => false);
                                } else {
                                  Navigator.of(_scaffoldKey.currentContext!)
                                      .pushReplacement(MaterialPageRoute(
                                          builder: (context) => Dashboard(0)));
                                }
                              } else {
                                CustomAlertDialogOnlyConfirm(
                                    _scaffoldKey.currentContext!, () {
                                  Navigator.pop(_scaffoldKey.currentContext!);
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
          )
        ]
      ]),
    );
  }
}
