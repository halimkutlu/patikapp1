// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/pages/feedbackSuccess.dart';
import 'package:patikmobile/widgets/icon_button.dart';
import 'package:sizer/sizer.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPage();
}

class _FeedbackPage extends State<FeedbackPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MainColors.backgroundColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(4.0.h),
            child: Text(
              "FeedbackDescription".tr,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.justify,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.0.h),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, border: Border.all(width: 0.1)),
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 8, //or null
                decoration: InputDecoration(fillColor: Colors.white),
              ),
            ),
          ),
          CustomIconButton(
            textColor: Colors.black,
            colors: MainColors.primaryColor,
            icons: Icon(Icons.send),
            name: 'send'.tr,
            width: 0.3.w,
            height: 2.5.h,
            onTap: () {
              if (true) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const FeedbackSuccess()));
              }
            },
          ),
        ],
      ),
    );
  }
}
