// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/models/training_select_names.dart';
import 'package:patikmobile/pages/box_page.dart';
import 'package:patikmobile/pages/games/fill_the_blank_game.dart';
import 'package:patikmobile/pages/games/match_moving_square_game.dart';
import 'package:patikmobile/pages/games/match_with_picture_game.dart';
import 'package:patikmobile/pages/games/math_with_sound_game.dart';
import 'package:patikmobile/pages/games/multiple_choice_game.dart';
import 'package:patikmobile/providers/trainingProvider.dart';
import 'package:patikmobile/widgets/box_widget.dart';
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
        body: Consumer<TrainingProvider>(builder: (context, provider, child) {
          if (!provider.wordsLoaded!) {
            // Eğer kelimeler yüklenmediyse bir yükleniyor ekranı göster
            return Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              Column(
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
            ],
          );
        }));
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
    return InkWell(
      onTap: () => playWithSelectedOptions(playWithEnum.allWords),
      child: Padding(
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
      ),
    );
  }

  Widget boxArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BoxWidget(
            text: AppLocalizations.of(context).translate("101"),
            color: MainColors.boxColor1,
            value: trainingProvider.getLernedWordCount.toString(),
            iconUrl: 'lib/assets/img/ilearned.png',
            onTap: () {
              playWithSelectedOptions(playWithEnum.learnedWords);
            },
          ),
          BoxWidget(
            text: AppLocalizations.of(context).translate("102"),
            color: MainColors.boxColor2,
            value: trainingProvider.getRepeatedWordCount.toString(),
            iconUrl: 'lib/assets/img/repeat.png',
            onTap: () {
              playWithSelectedOptions(playWithEnum.repeatedWords);
            },
          ),
          BoxWidget(
            text: AppLocalizations.of(context).translate("103"),
            color: MainColors.boxColor3,
            value: trainingProvider.getWorkHardCount.toString(),
            iconUrl: 'lib/assets/img/sun.png',
            onTap: () {
              playWithSelectedOptions(playWithEnum.workHardWords);
            },
          ),
        ],
      ),
    );
  }

  playWithSelectedOptions(playWithEnum playWith) {
    if (widget.selectedGame == trainingSelectNames.pictureWordMatching) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MatchWithPictureGame(
                trainingGame: true,
                playWith: playWith,
              )));
    } else if (widget.selectedGame == trainingSelectNames.soundWordMatching) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MatchWithSoundGame(
                trainingGame: true,
                playWith: playWith,
              )));
    } else if (widget.selectedGame == trainingSelectNames.WordTetris) {
      // Navigator.of(context)
      //     .push(MaterialPageRoute(builder: (context) => MovingSquaresGame()));
    } else if (widget.selectedGame == trainingSelectNames.LetterPuzzle) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => FillTheBlankGame(
                trainingGame: true,
                playWith: playWith,
              )));
    } else if (widget.selectedGame == trainingSelectNames.FiveOptions) {
      // Navigator.of(context)
      //     .push(MaterialPageRoute(builder: (context) => MultipleChoiceGame()));
    }
  }
}
