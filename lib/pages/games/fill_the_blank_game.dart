// ignore_for_file: prefer_const_constructors

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/providers/games_providers/fill_the_blank_game.dart';
import 'package:patikmobile/services/ad_helper.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';
import 'package:patikmobile/widgets/keyboard_widget.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class FillTheBlankGame extends StatefulWidget {
  const FillTheBlankGame({super.key});

  @override
  State<FillTheBlankGame> createState() => _FillTheBlankGameState();
}

class _FillTheBlankGameState extends State<FillTheBlankGame> {
  BannerAd? _bannerAd;

  late FillTheBlankGameProvider fillTheBlankGameProvide;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fillTheBlankGameProvide =
        Provider.of<FillTheBlankGameProvider>(context, listen: false);
    fillTheBlankGameProvide.init(context);

    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
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
    // TODO: Dispose a BannerAd object
    _bannerAd?.dispose();
    // TODO: Dispose an InterstitialAd object
    fillTheBlankGameProvide.interstitialAd.dispose();
    super.dispose();
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
          setState(() {
            fillTheBlankGameProvide.resetData();
            // imageList = [];
            // wordList = [];
          });
        });
      },
      child: Scaffold(
          backgroundColor: MainColors.backgroundColor,
          body: Consumer<FillTheBlankGameProvider>(
              builder: (context, provider, child) {
            if (!provider.wordsLoaded!) {
              // Eğer kelimeler yüklenmediyse bir yükleniyor ekranı göster
              return Center(child: CircularProgressIndicator());
            }
            // else if (imageList.isEmpty || wordList.isEmpty) {
            //   imageList = List.from(provider.wordListDbInformation!);
            //   wordList = List.from(provider.wordListDbInformation!);
            //   imageList.shuffle();
            //   wordList.shuffle();
            // }
            return Stack(
              children: [
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
                if (provider.wordsLoaded!)
                  Container(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(provider.selectedWordTextEditingController!.text,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      NumericKeypad(provider: provider)
                    ],
                  )),
                if (provider.errorAccuried == true) ...[
                  Positioned(child: ErrorImage()),
                ],
              ],
            );
          })),
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
