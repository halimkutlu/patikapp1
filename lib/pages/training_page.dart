// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, non_constant_identifier_names

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/pages/training_select_page.dart';
import 'package:patikmobile/models/training_select_names.dart';
import 'package:sizer/sizer.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MainColors.backgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Header(), CardList()],
        ));
  }

  Widget Header() {
    return Padding(
      padding: const EdgeInsets.all(38.0),
      child: Container(
        height: 5.h,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(40))),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 6.w,
                  height: 6.w,
                  child: Image.asset(
                    'lib/assets/img/muscle.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AutoSizeText(
                  maxLines: 1,
                  AppLocalizations.of(context).translate("98"),
                  style: TextStyle(fontSize: 2.1.h),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget CardList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
                Color(0xff009883),
                AppLocalizations.of(context).translate("149"),
                trainingSelectNames.pictureWordMatching),
            Card(
                Color(0xff0087C3),
                AppLocalizations.of(context).translate("150"),
                trainingSelectNames.soundWordMatching)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
                Color(0xffCC3BFF),
                AppLocalizations.of(context).translate("151"),
                trainingSelectNames.LetterPuzzle),
            Card(
                Color(0xffE8233D),
                AppLocalizations.of(context).translate("152"),
                trainingSelectNames.FiveOptions)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
                Color(0xff998E00),
                AppLocalizations.of(context).translate("153"),
                trainingSelectNames.WordTetris),
          ],
        )
      ],
    );
  }

  Widget Card(Color color, String name, trainingSelectNames game) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TrainingSelect(
                  name: name,
                  selectedGame: game,
                  color: color,
                )));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 30.w,
          width: 40.w,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    child: Image.asset(
                      'lib/assets/img/muscle.png',
                      color: Colors.white,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AutoSizeText(
                    maxLines: 2,
                    name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 2.1.h,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
