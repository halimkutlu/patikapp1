// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, non_constant_identifier_names

import 'dart:io';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/models/training_select_names.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/providers/games_providers/fill_the_blank_game.dart';
import 'package:patikmobile/services/ad_helper.dart';
import 'package:patikmobile/widgets/customAlertDialog.dart';
import 'package:patikmobile/widgets/keyboard_widget.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class FillTheBlankGame extends StatefulWidget {
  final bool? trainingGame;
  final playWithEnum? playWith;
  const FillTheBlankGame({super.key, this.trainingGame = false, this.playWith});

  @override
  State<FillTheBlankGame> createState() => _FillTheBlankGameState();
}

class _FillTheBlankGameState extends State<FillTheBlankGame> {
  BannerAd? _bannerAd;
  late AdProvider adProvider;

  late FillTheBlankGameProvider fillTheBlankGameProvide;
  @override
  void initState() {
    super.initState();
    fillTheBlankGameProvide =
        Provider.of<FillTheBlankGameProvider>(context, listen: false);
    fillTheBlankGameProvide.init(context, widget.playWith,
        trainingGame: widget.trainingGame!);
    adProvider = Provider.of<AdProvider>(context, listen: false);
    adProvider.init(context, (ad) {
      setState(() => _bannerAd = ad);
    });
  }

  @override
  void dispose() {
    if (_bannerAd != null) _bannerAd!.dispose();
    if (fillTheBlankGameProvide.interstitialAd != null) {
      fillTheBlankGameProvide.interstitialAd!.dispose();
    }
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
          appBar: !Platform.isAndroid
              ? AppBar(
                  toolbarHeight: 3.1.h,
                  backgroundColor: MainColors.backgroundColor,
                  elevation: 0.0,
                  centerTitle: true,
                  leading: InkWell(
                    onTap: () async {
                      await askToGoMainMenu(func: () {
                        setState(() {
                          fillTheBlankGameProvide.resetData();
                        });
                      });
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black54,
                    ),
                  ),
                )
              : null,
          backgroundColor: MainColors.backgroundColor,
          body: Consumer<FillTheBlankGameProvider>(
              builder: (context, provider, child) {
            if (!provider.wordsLoaded!) {
              // Eğer kelimeler yüklenmediyse bir yükleniyor ekranı göster
              return Center(child: CircularProgressIndicator());
            }
            return Stack(
              children: [
                if (_bannerAd != null)
                  Positioned(
                    bottom: 0,
                    height: _bannerAd!.size.height.toDouble(),
                    width: MediaQuery.of(context).size.width,
                    child: Center(child: AdWidget(ad: _bannerAd!)),
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
