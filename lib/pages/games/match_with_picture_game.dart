// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, avoid_unnecessary_containers

import 'dart:io';
import 'dart:math';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/models/training_select_names.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/providers/games_providers/match_with_picture_game_provider.dart';
import 'package:patikmobile/services/ad_helper.dart';
import 'package:patikmobile/widgets/customAlertDialog.dart';
import 'package:patikmobile/widgets/error_image.dart';
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
  late AdProvider adProvider;

  @override
  void initState() {
    super.initState();
    matchWithPictureGameProvide =
        Provider.of<MatchWithPictureGameProvide>(context, listen: false);
    matchWithPictureGameProvide.init(context, widget.playWith,
        trainingGame: widget.trainingGame!);

    adProvider = Provider.of<AdProvider>(context, listen: false);
    adProvider.init(context, (ad) {
      setState(() => _bannerAd = ad);
    });
  }

  @override
  void dispose() {
    if (_bannerAd != null) _bannerAd!.dispose();
    if (matchWithPictureGameProvide.interstitialAd != null) {
      matchWithPictureGameProvide.interstitialAd!.dispose();
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
        await askToGoMainMenu(context, func: () {
          setState(() {
            matchWithPictureGameProvide.resetData();
            matchWithPictureGameProvide.setUIimage = [];
            matchWithPictureGameProvide.setUIWord = [];
          });
        });
      },
      child: Scaffold(
        appBar: !Platform.isAndroid
            ? AppBar(
                toolbarHeight: 4.2.h,
                backgroundColor: MainColors.backgroundColor,
                elevation: 0.0,
                centerTitle: true,
                leading: InkWell(
                  onTap: () async {
                    await askToGoMainMenu(context, func: () {
                      setState(() {
                        matchWithPictureGameProvide.resetData();
                        matchWithPictureGameProvide.setUIimage = [];
                        matchWithPictureGameProvide.setUIWord = [];
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
              kelimeListesiniSirala(matchWithPictureGameProvide
                  .UIimageList); // kelime, kelimeye ait resim ile yan yana gelmesin
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

  void kelimeListesiniSirala(List<WordListDBInformation> resimListesi) {
    matchWithPictureGameProvide.UIwordList.shuffle();
    for (int i = 0; i < resimListesi.length; i++) {
      if (resimListesi[i] == matchWithPictureGameProvide.UIwordList[i]) {
        kelimeListesiniSirala(resimListesi);
        break;
      }
    }
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    info.word!,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}
