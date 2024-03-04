// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:patikmobile/api/static_variables.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/models/training_select_names.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/providers/games_providers/match_moving_square_game_provider.dart';
import 'package:patikmobile/services/ad_helper.dart';
import 'package:patikmobile/services/sound_helper.dart';
import 'package:patikmobile/widgets/customAlertDialog.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class GameSizeClass {
  static double Height = StaticVariables.AppSize.height;
  static double Width = StaticVariables.AppSize.width;
  static Size boxSize = Size(0, 0);
  static double boxEndPosition = 0;
  static double bottomMargin = 0;
  static double firstBoxOffset = 0;
  static double secondBoxOffset = 0;
  static double perMargin = 0;
  void Init() {
    // Aşağıda duracakları konum
    bottomMargin = Height - 2.h;
    // Kutu boyutu
    boxSize = Size((Width - 5.h) / 2, Height / 10);

    var margin = (Width - (boxSize.width * 2)) / 3;
    // ilk kutu left
    firstBoxOffset = margin;
    // ikinci kutu left
    secondBoxOffset = boxSize.width + (margin * 2);
  }
}

class MovingSquaresGame extends StatefulWidget {
  final bool? trainingGame;
  final playWithEnum? playWith;
  const MovingSquaresGame(
      {super.key, this.trainingGame = false, this.playWith});

  @override
  _MovingSquaresGame createState() => _MovingSquaresGame();
}

class _MovingSquaresGame extends State<MovingSquaresGame>
    with TickerProviderStateMixin {
  BannerAd? _bannerAd;

  late MovingSquaresGameProvide movingSquaresGameProvide;
  late List<AnimationController> _controllers;
  // late List<List<Offset>> squareOffsets;
  // animasyon hızı
  int durationSec = 40;
  @override
  void initState() {
    super.initState();

    movingSquaresGameProvide =
        Provider.of<MovingSquaresGameProvide>(context, listen: false);
    movingSquaresGameProvide.init(context, methodCallBack, methodCallBack2,
        widget.playWith, widget.trainingGame!);

    animationReload();

    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
            if (_bannerAd?.size != null && _bannerAd!.size.height > 0) {
              GameSizeClass.bottomMargin =
                  GameSizeClass.Height - _bannerAd!.size.height;
            }
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    for (var element in _controllers) {
      element.dispose();
    }

    super.dispose();
  }

  bool firstWordListened = false;
  void methodCallBack() {
    _controllers[movingSquaresGameProvide.siradaki!].addListener(() {
      setState(() {
        movingSquaresGameProvide.moveSquares(context, _controllers);
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!firstWordListened) {
        PlayAudio(movingSquaresGameProvide
            .currentGameItems![movingSquaresGameProvide.siradaki!].sound);
      }

      _controllers[movingSquaresGameProvide.siradaki!].forward();
      firstWordListened = true;
    });
  }

  void animationReload() {
    _controllers = [
      AnimationController(
        vsync: this,
        duration: Duration(seconds: durationSec),
      ),
      AnimationController(
        vsync: this,
        duration: Duration(seconds: durationSec),
      ),
      AnimationController(
        vsync: this,
        duration: Duration(seconds: durationSec),
      ),
      AnimationController(
        vsync: this,
        duration: Duration(seconds: durationSec),
      ),
      AnimationController(
        vsync: this,
        duration: Duration(seconds: durationSec),
      )
    ];
  }

  void methodCallBack2() {
    animationReload();
    firstWordListened = false;
    methodCallBack();
  }

  void gestureOnTapDown(
      TapDownDetails details, MovingSquaresGameProvide provider) async {
    if (provider.siradaki! > 4) return;
    Offset leftSquarePosition =
        provider.currentGameItems![provider.siradaki!].Wordoffsets![0];
    Offset rightSquarePosition =
        provider.currentGameItems![provider.siradaki!].Wordoffsets![1];

    if (leftSquarePosition.dy >= GameSizeClass.boxEndPosition) return;

    Offset position = details.localPosition;

    if (leftSquarePosition.dx <= position.dx &&
        leftSquarePosition.dx + GameSizeClass.boxSize.width >= position.dx &&
        leftSquarePosition.dy <= position.dy &&
        leftSquarePosition.dy + GameSizeClass.boxSize.height >= position.dy) {
      setState(() {
        provider.setIsClicked = true;
      });
      _controllers[provider.siradaki!].stop();

      if (provider.currentGameItems![provider.siradaki!].trueIndex == 0) {
        ShowSuccess(provider);
      } else {
        ShowError(provider);
      }
    }

    if (rightSquarePosition.dx <= position.dx &&
        rightSquarePosition.dx + GameSizeClass.boxSize.width >= position.dx &&
        rightSquarePosition.dy <= position.dy &&
        rightSquarePosition.dy + GameSizeClass.boxSize.height >= position.dy) {
      setState(() {
        provider.setIsClicked = true;
      });
      _controllers[provider.siradaki!].stop();
      if (provider.currentGameItems![provider.siradaki!].trueIndex == 1) {
        ShowSuccess(provider);
      } else {
        ShowError(provider);
      }
    }
  }

  void ShowError(MovingSquaresGameProvide provider) {
    provider.wrongAnswer(provider.currentGameItems![provider.siradaki!], () {
      provider.countError(provider.currentGameItems![provider.siradaki!]);
      provider.setErrorAccuried = false;
      provider.boxDown();
      methodCallBack();
    });
  }

  void ShowSuccess(MovingSquaresGameProvide provider) {
    provider.successAnswer(provider.currentGameItems![provider.siradaki!], () {
      provider.setSuccessAccuried = false;
      provider.boxDown();
      methodCallBack();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
          await askToGoMainMenu(func: () {
            setState(() {});
          });
        },
        child: Scaffold(
          backgroundColor: MainColors.backgroundColor,
          body: Consumer<MovingSquaresGameProvide>(
            builder: (context, provider, child) {
              return Stack(children: [
                if (_bannerAd != null)
                  Positioned(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: _bannerAd!.size.width.toDouble() * 2,
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                  ),
                GestureDetector(
                  child: CustomPaint(
                    painter: SquarePainter(provider.currentGameItems!, context),
                    size: Size.infinite,
                  ),
                  onTapDown: (details) => gestureOnTapDown(details, provider),
                ),
                Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                        width: StaticVariables.AppSize.width,
                        height: GameSizeClass.boxSize.height / 1.2,
                        decoration:
                            BoxDecoration(color: MainColors.backgroundColor))),
                if (provider.errorAccuried == true) ...[
                  Positioned(child: ErrorImage()),
                ],
                if (provider.successAccuried == true) ...[
                  Positioned(child: SuccessImage()),
                ],
              ]);
            },
          ),
        ));
  }

  Widget SuccessImage() {
    return Container(
      color: const Color.fromARGB(42, 255, 255, 255),
      child: Center(
        child: Image.asset(
          'lib/assets/img/success_image.png',
          width: 42.w,
          height: 20.h,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget ErrorImage() {
    return Container(
      color: Color.fromARGB(42, 255, 255, 255),
      child: Center(
        child: Image.asset(
          'lib/assets/img/error_image.png',
          width: 42.w,
          height: 20.h,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<void> askToGoMainMenu({VoidCallback? func}) async {
    await CustomAlertDialog(context, () {
      if (func != null) {
        func();
      }
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Dashboard(0)),
          (Route<dynamic> route) => false);
    },
        "Emin misiniz?",
        "Eğitimi bitirmek istiyormusunuz. Gelişmeleriniz kaydedilmeyecektir.",
        ArtSweetAlertType.question,
        "Tamam",
        "Geri");
  }
}

class SquarePainter extends CustomPainter {
  final List<GameItem> gameItem;
  final BuildContext context;

  SquarePainter(this.gameItem, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [Color(0xffE5381E), Color(0xffF77440), Color(0xffFB7E3F)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    Paint paint2 = Paint()
      ..shader = LinearGradient(
        colors: [
          Color(0xff388C87),
          Color(0xff68E1FD),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    for (var offsetList in gameItem) {
      for (var offset in offsetList.Wordoffsets!) {
        var index = offsetList.Wordoffsets!.indexOf(offset);

        Path path = Path();
        path.addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(offset.dx, offset.dy, GameSizeClass.boxSize.width,
                GameSizeClass.boxSize.height),
            Radius.circular(10)));

        canvas.drawPath(path, index == 0 ? paint : paint2);
        List<String> wordList = [];
        wordList = offsetList.words![index]
            .split(" ")
            .where((element) => element != "")
            .toList();
        var wordString = wordList.join("\n");
        // Metni karenin tam ortasına yerleştirme
        final textPainter = TextPainter(
            text: TextSpan(
              text: wordString,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center);
        textPainter.layout();
        textPainter.paint(
            canvas,
            Offset(
                offset.dx +
                    (GameSizeClass.boxSize.width - textPainter.width) / 2,
                offset.dy +
                    (GameSizeClass.boxSize.height - textPainter.height) / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
