// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers

import 'dart:math';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/providers/games_providers/match_with_sound_game_provider.dart';
import 'package:patikmobile/services/ad_helper.dart';
import 'package:patikmobile/services/sound_helper.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class MatchWithSoundGame extends StatefulWidget {
  const MatchWithSoundGame({super.key});

  @override
  State<MatchWithSoundGame> createState() => _MatchWithSoundGameState();
}

class _MatchWithSoundGameState extends State<MatchWithSoundGame> {
  BannerAd? _bannerAd;

  late MatchWithSoundGameProvide matchWithSoundGameProvide;

  List<WordListDBInformation> soundList = [];
  List<WordListDBInformation> wordList = [];
  @override
  void initState() {
    super.initState();
    matchWithSoundGameProvide =
        Provider.of<MatchWithSoundGameProvide>(context, listen: false);
    matchWithSoundGameProvide.init(context);

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
    _bannerAd?.dispose();
    matchWithSoundGameProvide.interstitialAd.dispose();
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
            matchWithSoundGameProvide.resetData();
            soundList = [];
            wordList = [];
          });
        });
      },
      child: Scaffold(
        backgroundColor: MainColors.backgroundColor,
        body: Consumer<MatchWithSoundGameProvide>(
          builder: (context, provider, child) {
            if (!provider.wordsLoaded!) {
              // Eğer kelimeler yüklenmediyse bir yükleniyor ekranı göster
              return Center(child: CircularProgressIndicator());
            } else if (soundList.isEmpty || wordList.isEmpty) {
              soundList = List.from(provider.wordListDbInformation!);
              wordList = List.from(provider.wordListDbInformation!);
              soundList.shuffle();
              wordList.shuffle();
            }
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
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: _buildSoundWidgets(soundList, provider),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: _buildWordWidgets(wordList, provider),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (provider.errorAccuried == true) ...[
                  Positioned(child: ErrorImage()),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildSoundWidgets(
      List<WordListDBInformation> list, MatchWithSoundGameProvide provider) {
    return list.map((info) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          child: Container(
            width: 20.w,
            height: 10.h,
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 247, 244, 244),
                border: Border.all(width: 0.2),
                borderRadius: BorderRadius.circular(20)),
            child: InkWell(
              onTap: () {
                PlayAudio(info.audio);
                if (info.isSoundCorrect != true) {
                  if (info.isSoundListened == null || !info.isSoundListened!) {
                    if (list
                        .any((element) => element.isSoundListened == true)) {
                      provider.resetSelectSound(info);

                      provider.selectSound(info);
                    } else {
                      provider.selectSound(info);
                    }
                  } else {
                    provider.resetSelectSound(info);
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  color: info.isSoundCorrect == true
                      ? Colors.green
                      : info.isSoundCorrect == false
                          ? Colors.red
                          : info.isSoundListened == true
                              ? Colors.orange
                              : Colors.lightBlue,
                  Icons.volume_up_outlined,
                  size: 6.h,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildWordWidgets(
      List<WordListDBInformation> list, MatchWithSoundGameProvide provider) {
    return list.map((info) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: info.isWordCorrect == true
              ? null
              : () => provider.selectWord(info, context),
          child: Container(
            width: 50.w,
            height: 10.h,
            decoration: BoxDecoration(
              border: Border.all(width: 0.2),
              borderRadius: BorderRadius.circular(20),
              color: info.isWordCorrect == true
                  ? Colors.green
                  : info.isWordCorrect == false
                      ? Colors.red
                      : info.isWordSelected == true
                          ? Colors.orange
                          : Color.fromARGB(255, 247, 244, 244),
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    info.word!,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (info.wordT?.isNotEmpty ?? false) ...[
                    Text(
                      info.wordT!,
                      style: TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                  if (info.wordA?.isNotEmpty ?? false) ...[
                    Text(
                      info.wordA!,
                      style: TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ]
                ]),
          ),
        ),
      );
    }).toList();
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