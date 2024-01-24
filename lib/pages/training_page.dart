import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
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
                  height: 3.h,
                  child: Image.asset(
                    'lib/assets/img/muscle.png',
                    width: 600.0,
                    height: 240.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 11.0.w),
              child: Card(
                  Color(0xff998E00),
                  AppLocalizations.of(context).translate("153"),
                  trainingSelectNames.WordTetris),
            ),
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
          height: 13.h,
          width: 35.w,
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
                    height: 3.h,
                    child: Image.asset(
                      'lib/assets/img/muscle.png',
                      width: 600.0,
                      height: 240.0,
                      color: Colors.white,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
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
