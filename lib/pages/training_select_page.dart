import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/models/training_select_names.dart';
import 'package:patikmobile/providers/trainingProvider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class TrainingSelect extends StatefulWidget {
  final trainingSelectNames selectedGame;
  final String name;
  final Color color;
  TrainingSelect(
      {super.key,
      required this.selectedGame,
      required this.name,
      required this.color});

  @override
  State<TrainingSelect> createState() => _TrainingSelectState();
}

class _TrainingSelectState extends State<TrainingSelect> {
  late TrainingProvider trainingProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    trainingProvider = Provider.of<TrainingProvider>(context, listen: false);
    trainingProvider.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainColors.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Card(widget.color, widget.name),
          ),
          Center(child: Header()),
          Center(
            child: boxArea(),
          ),
          Center(
            child: HeaderPlayWithAllLang(),
          )
        ],
      ),
    );
  }

  Widget Card(Color color, String name) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 13.h,
        width: 35.w,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.all(Radius.circular(20))),
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
    );
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppLocalizations.of(context).translate("155"),
                  style: TextStyle(fontSize: 2.1.h),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget HeaderPlayWithAllLang() {
    return Padding(
      padding: const EdgeInsets.all(38.0),
      child: Container(
        height: 5.h,
        decoration: BoxDecoration(
            color: Color(0xffF8BBC3),
            borderRadius: BorderRadius.all(Radius.circular(15))),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppLocalizations.of(context).translate("156"),
                  style: TextStyle(fontSize: 2.1.h),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget boxArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          box(
            AppLocalizations.of(context).translate("101"),
            MainColors.boxColor1,
            trainingProvider.getLernedWordCount.toString(),
            'lib/assets/img/ilearned.png',
          ),
          box(
            AppLocalizations.of(context).translate("102"),
            MainColors.boxColor2,
            trainingProvider.getRepeatedWordCount.toString(),
            'lib/assets/img/repeat.png',
          ),
          box(
            AppLocalizations.of(context).translate("103"),
            MainColors.boxColor3,
            trainingProvider.getWorkHardCount.toString(),
            'lib/assets/img/sun.png',
          ),
        ],
      ),
    );
  }

  Widget box(String text, Color color, String value, String iconUrl) {
    return Column(
      children: [
        Container(
          height: 3.h,
          width: 25.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(3),
                  bottomRight: Radius.circular(3)),
              color: color,
              border: Border.all(width: 3, color: Colors.black38)),
          child: Center(
              child: AutoSizeText(
            text,
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
        ),
        Container(
          height: 8.h,
          width: 23.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              color: color,
              border: Border.all(width: 3, color: Colors.black38)),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0.1.h),
                child: Image.asset(
                  iconUrl,
                  width: 6.w,
                  height: 3.h,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.5.h, right: 2.w, left: 2.w),
                child: Container(
                  color: Colors.white,
                  child: Center(
                      child: AutoSizeText(
                    value,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
