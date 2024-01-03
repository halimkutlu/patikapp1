// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, use_build_context_synchronously

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/providers/loginProvider.dart';
import 'package:patikmobile/widgets/customAlertDialog.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';
import 'package:patikmobile/widgets/loading_bar.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../models/language.model.dart';

class SelectLearnLanguage extends StatefulWidget {
  const SelectLearnLanguage({super.key});

  @override
  State<SelectLearnLanguage> createState() => _SelectLearnLanguageState();
}

class _SelectLearnLanguageState extends State<SelectLearnLanguage> {
  late LoginProvider loginProvider;
  List<dynamic> llanguage = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save a reference to the ancestor here
    loginProvider = Provider.of<LoginProvider>(context);
  }

  @override
  void dispose() {
    // Use the saved reference here in dispose()
    // Make sure to check if the widget is mounted before accessing it
    if (mounted) {
      loginProvider.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    if (Languages.LngList.isEmpty) loginProvider.getLearnLanguage(context);

    return Scaffold(
      body: Stack(children: [
        SingleChildScrollView(
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
                              'lib/assets/learn_language.png',
                              fit: BoxFit.cover,
                              height: 2.3.h,
                            ),
                          ),
                          Text(
                            "chooseLearnLanguage".tr,
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: Languages.LngList.length,
                  itemBuilder: (BuildContext context, int index) {
                    var language = Languages.LngList[index];
                    return InkWell(
                      onTap: () {
                        CustomAlertDialog(context, () async {
                          Navigator.pop(context);
                          FileDownloadStatus status = await loginProvider
                              .startProcessOfDownloadLearnLanguage(
                                  language.Code,
                                  context,
                                  language.Name!,
                                  language.LCID);

                          if (status.status) {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => Dashboard()));
                          } else {
                            CustomAlertDialogOnlyConfirm(context, () {
                              Navigator.pop(context);
                            }, "error".tr, status.message,
                                ArtSweetAlertType.danger, "ok".tr);
                          }
                        },
                            "areYouSure".tr,
                            language.Name.toString() +
                                " " +
                                "choosenLearnLanguage".tr,
                            ArtSweetAlertType.question,
                            "ok".tr,
                            "no".tr);
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
                              language.Name!,
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
        Container(child: loginProvider.loading ? Loading() : Container())
      ]),
    );
  }
}
