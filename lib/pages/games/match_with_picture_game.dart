// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'dart:math';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/models/training_select_names.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/providers/games_providers/match_with_picture_game_provider.dart';
import 'package:patikmobile/services/ad_helper.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class MatchWithPictureGame extends StatefulWidget {
  final bool? trainingGame;
  final playWithEnum? playWith;

  const MatchWithPictureGame(
      {super.key, this.trainingGame = false, this.playWith});

  @override
  State<MatchWithPictureGame> createState() => _MatchWithPictureGameState();
}

class _MatchWithPictureGameState extends State<MatchWithPictureGame> {
  BannerAd? _bannerAd;

  late MatchWithPictureGameProvide matchWithPictureGameProvide;

  @override
  void initState() {
    super.initState();
    matchWithPictureGameProvide =
        Provider.of<MatchWithPictureGameProvide>(context, listen: false);
    matchWithPictureGameProvide.init(context, widget.playWith,
        trainingGame: widget.trainingGame!);

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
    matchWithPictureGameProvide.interstitialAd.dispose();
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
            matchWithPictureGameProvide.resetData();
            matchWithPictureGameProvide.setUIimage = [];
            matchWithPictureGameProvide.setUIWord = [];
          });
        });
      },
      child: Scaffold(
        backgroundColor: MainColors.backgroundColor,
        body: Consumer<MatchWithPictureGameProvide>(
          builder: (context, provider, child) {
            if (!provider.wordsLoaded!) {
              // Eğer kelimeler yüklenmediyse bir yükleniyor ekranı göster
              return Center(child: CircularProgressIndicator());
            } else if (matchWithPictureGameProvide.UIimageList.isEmpty ||
                matchWithPictureGameProvide.UIwordList.isEmpty) {
              matchWithPictureGameProvide.setUIimage =
                  List.from(provider.wordListDbInformation!);
              matchWithPictureGameProvide.setUIWord =
                  List.from(provider.wordListDbInformation!);
              matchWithPictureGameProvide.UIimageList.shuffle();
              matchWithPictureGameProvide.UIwordList.shuffle();
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
                            children: _buildImageWidgets(
                                matchWithPictureGameProvide.UIimageList,
                                provider),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: _buildWordWidgets(
                                matchWithPictureGameProvide.UIwordList,
                                provider),
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

  List<Widget> _buildImageWidgets(
      List<WordListDBInformation> list, MatchWithPictureGameProvide provider) {
    return list.map((info) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: info.isImageCorrect == true
              ? () {}
              : () {
                  if (info.isImageSelected == null || !info.isImageSelected!) {
                    if (list
                        .any((element) => element.isImageSelected == true)) {
                      provider.resetSelectImage(info);

                      provider.selectImage(info);
                    } else {
                      provider.selectImage(info);
                    }
                  } else {
                    provider.resetSelectImage(info);
                  }
                },
          child: Container(
            width: 20.w,
            height: 10.h,
            decoration: BoxDecoration(
              border: Border.all(width: 0.2),
              borderRadius: BorderRadius.circular(8),
              color: info.isImageCorrect == true
                  ? Colors.green
                  : info.isImageCorrect == false
                      ? Colors.red
                      : info.isImageSelected == true
                          ? Colors.orange
                          : Colors.white,
            ),
            child: SvgPicture.memory(
              info.imageBytes!,
              height: 19.h,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildWordWidgets(
      List<WordListDBInformation> list, MatchWithPictureGameProvide provider) {
    return list.map((info) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: info.isWordCorrect == true
              ? () {}
              : () {
                  provider.selectWord(info, context);
                },
          child: Container(
            width: 50.w,
            height: 10.h,
            decoration: BoxDecoration(
              border: Border.all(width: 0.2),
              borderRadius: BorderRadius.circular(8),
              color: info.isWordCorrect == true
                  ? Colors.green
                  : info.isWordCorrect == false
                      ? Colors.red
                      : info.isWordSelected == true
                          ? Colors.orange
                          : Colors.white,
            ),
            child: Center(
              child: Text(
                info.word!,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
