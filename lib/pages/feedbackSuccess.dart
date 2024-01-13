// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patikmobile/assets/mainColors.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/widgets/icon_button.dart';
import 'package:sizer/sizer.dart';

class FeedbackSuccess extends StatefulWidget {
  const FeedbackSuccess({super.key});

  @override
  State<FeedbackSuccess> createState() => _FeedbackSuccess();
}

class _FeedbackSuccess extends State<FeedbackSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MainColors.backgroundColor,
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 4.0.h, bottom: 1.h),
              child: Text(
                "FeedbackSuccessTitle".tr,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 2.5.h),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
          Text(
            "FeedbackSuccessDescription".tr,
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.justify,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomIconButton(
              textColor: Colors.black,
              colors: MainColors.primaryColor,
              icons: Icon(Icons.send),
              name: 'backToMainPage'.tr,
              width: 0.3.w,
              height: 2.5.h,
              onTap: () {
                if (true) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const Dashboard(0)));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
