// ignore_for_file: non_constant_identifier_names, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:patikmobile/providers/dialogCategoriesProvider.dart';
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
                  children: [
                    Expanded(
                        child: ListView.builder(
                            itemCount: provider.categoryList.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {},
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 8.0.w, right: 8.0.w, bottom: 1.h),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                                0.2), // Gölge rengi ve opaklık
                                            spreadRadius: 2, // Yayılma alanı
                                            blurRadius:
                                                1, // Bulanıklık yarıçapı
                                            offset: const Offset(
                                                0, 2), // Gölge offset
                                          ),
                                        ],
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(7))),
                                    padding: const EdgeInsets.all(50),
                                    // Arka plan rengi
                                    child: Center(
                                      child: Text(
                                        provider.categoryList[index]
                                            .categoryAppLngName!,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 1.7.h), // Metin rengi
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }))
                  ],
                ),
              ],
            );
          })),
    );
  }
}
