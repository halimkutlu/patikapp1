// ignore_for_file: non_constant_identifier_names, avoid_print, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:patikmobile/api/static_variables.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/models/user_roles.dart';
import 'package:patikmobile/pages/dialog_page.dart';
import 'package:patikmobile/providers/dialogCategoriesProvider.dart';
import 'package:patikmobile/services/image_helper.dart';
import 'package:patikmobile/widgets/icon_button.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:patikmobile/assets/style/mainColors.dart';

class SelectDialogCategory extends StatefulWidget {
  const SelectDialogCategory({super.key});

  @override
  State<SelectDialogCategory> createState() => _SelectDialogCategoryState();
}

class _SelectDialogCategoryState extends State<SelectDialogCategory> {
  late DialogCategoriesProvider provider;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    provider = Provider.of<DialogCategoriesProvider>(context, listen: false);
    provider.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
          backgroundColor: MainColors.backgroundColor,
          body: Consumer<DialogCategoriesProvider>(
              builder: (context, provider, child) {
            if (!provider.isLoadList) {
              // Eğer kelimeler yüklenmediyse bir yükleniyor ekranı göster
              return const Center(child: CircularProgressIndicator());
            }
            return Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (StaticVariables.lngPlanType <= LngPlanType.Free) ...[
                      Center(
                          heightFactor: 3.h,
                          child: AutoSizeText(
                              AppLocalizations.of(context).translate("72"),
                              style: TextStyle(
                                color: Color(0xFF605E5E),
                                fontSize: 14,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                height: 0.10,
                              ))),
                      CustomIconButton(
                        textSize: 20,
                        height: 2.7.h,
                        textInlinePadding: 3.h,
                        width: 0.3.h,
                        colors: Colors.red,
                        name: AppLocalizations.of(context).translate("73"),
                      )
                    ] else ...[
                      Expanded(
                          child: ListView.builder(
                              itemCount: provider.categoryList.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => DialogPage(
                                                dialogId: provider
                                                    .categoryList[index]
                                                    .dbId!)));
                                  },
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 0.8.h,
                                          left: 8.0.w,
                                          right: 8.0.w,
                                          bottom: 0.7.h),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                238, 255, 255, 255),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                    0.5), // Gölge rengi ve opaklık
                                                spreadRadius:
                                                    1, // Yayılma alanı
                                                blurRadius:
                                                    1, // Bulanıklık yarıçapı
                                                offset: const Offset(
                                                    0, 1), // Gölge offset
                                              ),
                                            ],
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        child: Column(children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 0.3.h, right: 1.h),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                      '${provider.categoryList[index].categoryDialogCount!} / ',
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 1.7.h)),
                                                  Text(
                                                      provider
                                                          .categoryList[index]
                                                          .totalCount!
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: Colors.red
                                                              .withOpacity(0.5),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 1.7.h))
                                                ]),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: getDialogBackground(
                                                        provider
                                                            .categoryList[index]
                                                            .dbId!,
                                                        provider
                                                            .categoryList[index]
                                                            .imgLngPath),
                                                    fit: BoxFit.cover)),
                                            padding: const EdgeInsets.all(10),

                                            // Arka plan rengi
                                            child: Center(
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    getDialogImage(
                                                        provider
                                                            .categoryList[index]
                                                            .dbId!,
                                                        provider
                                                            .categoryList[index]
                                                            .imgLngPath),
                                                    AutoSizeText(
                                                      provider
                                                          .categoryList[index]
                                                          .categoryAppLngName!,
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 2.2
                                                              .h), // Metin rengi
                                                    ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 1.h))
                                                  ]),
                                            ),
                                          )
                                        ]),
                                      )),
                                );
                              }))
                    ]
                  ],
                ),
              ],
            );
          })),
    );
  }
}
