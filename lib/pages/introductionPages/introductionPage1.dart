// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/providers/introductionPageProvider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class IntroductionPage1 extends StatefulWidget {
  const IntroductionPage1({super.key});

  @override
  State<IntroductionPage1> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<IntroductionPage1> {
  @override
  void initState() {
    final introProvider =
        Provider.of<IntroductionPageProvider>(context, listen: false);
    introProvider.initData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final introProvider = Provider.of<IntroductionPageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        toolbarHeight: 60.h,
        backgroundColor: MainColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(140),
          ),
        ),
        title: Column(
          children: [
            Container(
              width: 150,
              height: 150,
              child: Image.asset(
                !introProvider.secondPage
                    ? 'lib/assets/img/intro_image_1.png'
                    : 'lib/assets/img/intro_image_2.png',
                width: 600.0,
                height: 240.0,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  introductionText(!introProvider.secondPage ? "1" : "2", 2.5),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child:
                  introductionText(!introProvider.secondPage ? "1" : "2", 2.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                roundedCircle(!introProvider.secondPage ? true : false, () {
                  setState(() => introProvider.changePage = false);
                }),
                roundedCircle(!introProvider.secondPage ? false : true, () {
                  setState(() => introProvider.changePage = true);
                })
              ],
            )
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 90,
            height: 90,
            child: Image.asset(
              'lib/assets/img/logo.png',
              width: 600.0,
              height: 240.0,
              fit: BoxFit.cover,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Button('skip', false, () {
                introProvider.skip(context);
              }),
              introProvider.secondPage
                  ? Button('login', true, () {
                      introProvider.goToLoginPage(context);
                    })
                  : Button('next', true, () {
                      introProvider.nextPage();
                    })
            ],
          )
        ],
      ),
    );
  }

  Widget roundedCircle(bool empty, Function()? func) {
    return InkWell(
      onTap: func,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 20,
          height: 20,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  child: Image.asset(
                    empty
                        ? 'lib/assets/img/dots_active.png'
                        : 'lib/assets/img/dots_passive.png',
                    width: 600.0,
                    height: 240.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget introductionText(String text, double fontSize) {
    return Container(
      child: Text(
        AppLocalizations.of(context).translate(text),
        textAlign: TextAlign.center,
        maxLines: 10,
        style: TextStyle(
            color: Color(0xFF7E7B7B),
            fontSize: fontSize.h,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            height: 1),
      ),
    );
  }

  Widget Button(String text, bool border, Function()? func) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: border
          ? ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: border
                      ? MaterialStateProperty.all(MainColors.primaryColor)
                      : MaterialStateProperty.all(Colors
                          .transparent), // Kenarlıksız için şeffaf renk kullanabilirsiniz
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          0.0), // Kenar yuvarlaklığı buradan ayarlayabilirsiniz
                    ),
                  ) // Kenarlıksız buton için shape null olmalı
                  ),
              onPressed: func,
              child: Text(
                text.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0F1011),
                  fontSize: 2.h,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          : InkWell(
              onTap: func,
              child: Text(
                text.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0F1011),
                  fontSize: 2.h,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
    );
  }
}
