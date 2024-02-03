// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names, prefer_const_constructors

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:patikmobile/api/static_variables.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/providers/games_providers/match_moving_square_game_provider.dart';
import 'package:patikmobile/services/ad_helper.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class GameSizeClass {
  static double Height = StaticVariables.AppSize.height;
  static double Width = StaticVariables.AppSize.width;
  static double boxSize = 0;
  static double boxEndPosition = 0;
  static double bottomMargin = 0;
  static double firstBoxOffset = 0;
  static double secondBoxOffset = 0;
  static double perMargin = 0;
  void Init() {
    // Aşağıda duracakları konum
    bottomMargin = Height - 3.h;
    // Kutu boyutu
    boxSize = (Height - 22.h) / 5;

    var margin = (Width - (boxSize * 2)) / 3;
    // ilk kutu left
    firstBoxOffset = margin;
    // ikinci kutu left
    secondBoxOffset = boxSize + (margin * 2);
  }
}

class MovingSquaresGame extends StatefulWidget {
  const MovingSquaresGame({super.key});

  @override
  _MovingSquaresGame createState() => _MovingSquaresGame();
}

class _MovingSquaresGame extends State<MovingSquaresGame>
    with TickerProviderStateMixin {
  BannerAd? _bannerAd;

  late MovingSquaresGameProvide movingSquaresGameProvide;
  late List<AnimationController> _controllers;
  late List<List<Offset>> squareOffsets;
  // animasyon hızı
  int durationSec = 15;
  @override
  void initState() {
    super.initState();

    movingSquaresGameProvide =
        Provider.of<MovingSquaresGameProvide>(context, listen: false);
    movingSquaresGameProvide.init(context);

    GameSizeClass().Init();
    // Karelerin başlangıç konumları
    squareOffsets = [
      [
        Offset(GameSizeClass.firstBoxOffset, -13.h),
        Offset(GameSizeClass.secondBoxOffset, -13.h)
      ],
      [
        Offset(GameSizeClass.firstBoxOffset, -13.h),
        Offset(GameSizeClass.secondBoxOffset, -13.h)
      ],
      [
        Offset(GameSizeClass.firstBoxOffset, -13.h),
        Offset(GameSizeClass.secondBoxOffset, -13.h)
      ],
      [
        Offset(GameSizeClass.firstBoxOffset, -13.h),
        Offset(GameSizeClass.secondBoxOffset, -13.h)
      ],
      [
        Offset(GameSizeClass.firstBoxOffset, -13.h),
        Offset(GameSizeClass.secondBoxOffset, -13.h)
      ]
    ];

    movingSquaresGameProvide =
        Provider.of<MovingSquaresGameProvide>(context, listen: false);
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
    _controllers[siradaki].addListener(() {
      setState(() {
        moveSquares();
      });
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _controllers[siradaki].forward();
    });

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

  int siradaki = 0;

  void moveSquares() {
    GameSizeClass.boxEndPosition = (GameSizeClass.bottomMargin -
        ((GameSizeClass.boxSize * (siradaki + 1)) + (siradaki * 2.h)));
    //siradaki kutuların konumu değiştiriliyor
    for (int i = 0; i < squareOffsets[siradaki].length; i++) {
      squareOffsets[siradaki][i] = Offset(
          squareOffsets[siradaki][i].dx, squareOffsets[siradaki][i].dy + 2);
    }
    //siradaki kutular belirlenen konuma geldiğinde bağlı animasyon dispose edilip varsa sıradaki çalıştırılıyor
    if (squareOffsets[siradaki][0].dy >= GameSizeClass.boxEndPosition) {
      _controllers[siradaki].stop();
      // _controllers[siradaki].dispose();
      // sonraki animasyona geçiliyor
      siradaki++;
      // sonuncu animasyondan sonra tekrar girmiyor
      if (siradaki < 5) {
        _controllers[siradaki].addListener(() {
          setState(() {
            moveSquares();
          });
        });
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          _controllers[siradaki].forward();
        });
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    for (var element in _controllers) {
      element.dispose();
    }

    super.dispose();
  }

  void gestureOnTapDown(TapDownDetails details) {
    Offset leftSquarePosition = squareOffsets[siradaki][0];
    Offset rightSquarePosition = squareOffsets[siradaki][1];

    if (leftSquarePosition.dy >= GameSizeClass.boxEndPosition) return;

    Offset position = details.localPosition;

    if (leftSquarePosition.dx <= position.dx &&
        leftSquarePosition.dx + GameSizeClass.boxSize >= position.dx &&
        leftSquarePosition.dy <= position.dy &&
        leftSquarePosition.dy + GameSizeClass.boxSize >= position.dy) {
      squareOffsets[siradaki][0] =
          Offset(squareOffsets[siradaki][0].dx, GameSizeClass.boxEndPosition);
      squareOffsets[siradaki][1] =
          Offset(squareOffsets[siradaki][1].dx, GameSizeClass.boxEndPosition);
      print("Birinciye tıklandı");
    }

    if (rightSquarePosition.dx <= position.dx &&
        rightSquarePosition.dx + GameSizeClass.boxSize >= position.dx &&
        rightSquarePosition.dy <= position.dy &&
        rightSquarePosition.dy + GameSizeClass.boxSize >= position.dy) {
      squareOffsets[siradaki][0] =
          Offset(squareOffsets[siradaki][0].dx, GameSizeClass.boxEndPosition);
      squareOffsets[siradaki][1] =
          Offset(squareOffsets[siradaki][1].dx, GameSizeClass.boxEndPosition);
      print("İkinciye tıklandı");
    }
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
                    painter: SquarePainter(squareOffsets, context),
                    size: Size.infinite,
                  ),
                  onTapDown: (details) => gestureOnTapDown(details),
                ),
                Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                        width: StaticVariables.AppSize.width,
                        height: GameSizeClass.boxSize - 100,
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
    await CustomAlertDialogOnlyConfirm(context, () {
      if (func != null) {
        func();
      }
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Dashboard(0)),
          (Route<dynamic> route) => false);
    },
        "warning".tr,
        "Eğitimi bitirmek istiyormusunuz. Gelişmeleriniz kaydedilmeyecektir.",
        ArtSweetAlertType.info,
        "ok".tr);
  }
}

class SquarePainter extends CustomPainter {
  final List<List<Offset>> squareOffsets;
  final BuildContext context;

  SquarePainter(this.squareOffsets, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.blue;
    for (var offsetList in squareOffsets) {
      for (var offset in offsetList) {
        Path path = Path();
        path.addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(offset.dx, offset.dy, GameSizeClass.boxSize,
                GameSizeClass.boxSize),
            Radius.circular(10)));

        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
