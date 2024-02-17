// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:io';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:patikmobile/providers/games_providers/swipe_card_game_provider.dart';
import 'package:patikmobile/services/ad_helper.dart';
import 'package:patikmobile/services/sound_helper.dart';
import 'package:patikmobile/widgets/customAlertDialog.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SwipeCardGame extends StatefulWidget {
  final WordListInformation? selectedCategoryInfo;
  const SwipeCardGame({super.key, this.selectedCategoryInfo});

  @override
  State<SwipeCardGame> createState() => _SwipeCardGameState();
}

class _SwipeCardGameState extends State<SwipeCardGame> {
  BannerAd? _bannerAd;
  bool contentLoaded = false;
  late SwipeCardGameProvider swipeCardProvider;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    swipeCardProvider =
        Provider.of<SwipeCardGameProvider>(context, listen: false);
    swipeCardProvider.init(widget.selectedCategoryInfo, context);

    // TODO: Load a banner ad
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
            swipeCardProvider.resetData();
          });
        });
      },
      child: Scaffold(
          backgroundColor: MainColors.backgroundColor,
          body: Consumer<SwipeCardGameProvider>(
              builder: (context, provider, child) {
            if (!provider.wordsLoaded!) {
              // Eğer kelimeler yüklenmediyse bir yükleniyor ekranı göster
              return Center(child: CircularProgressIndicator());
            }
            return Stack(
              children: [
                if (provider.wordsLoaded == true) ...[
                  CardSwiper(
                    onEnd: () {
                      provider.goToNextGame(context);
                    },
                    backCardOffset: Offset(-25, -40),
                    cardsCount: provider.wordsLoaded == true
                        ? provider.wordListDbInformation!.length
                        : 1,
                    cardBuilder:
                        (context, index, percentThresholdX, percentThresholdY) {
                      return Center(
                        child: Container(
                          height: 80.h,
                          decoration: BoxDecoration(
                            color: MainColors.primaryColor,
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                            border: Border.all(width: 0.2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              !provider.wordListDbInformation![index].lastCard!
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            PlayAudio(provider
                                                .wordListDbInformation![index]
                                                .audio);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.volume_up_outlined,
                                              size: 6.h,
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  : Container(),
                              Column(
                                children: [
                                  Text(
                                    provider.wordListDbInformation![index]
                                            .word ??
                                        "",
                                    style: TextStyle(
                                        fontSize: 3.2.h, color: Colors.black),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(1.0.h),
                                    child: Text(
                                      provider.wordListDbInformation![index]
                                              .wordA ??
                                          "",
                                      style: TextStyle(
                                          fontSize: 2.3.h,
                                          color: Colors.black54),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(0.h),
                                    child: Text(
                                      provider.wordListDbInformation![index]
                                              .wordT ??
                                          "",
                                      style: TextStyle(
                                          fontSize: 2.3.h,
                                          color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  !provider.wordListDbInformation![index]
                                          .lastCard!
                                      ? SvgPicture.memory(
                                          provider.wordListDbInformation![index]
                                              .imageBytes!,
                                          height: 19.h,
                                        )
                                      : Container(),
                                  Padding(
                                    padding: EdgeInsets.all(4.0.h),
                                    child: Text(
                                      provider.wordListDbInformation![index]
                                              .wordAppLng ??
                                          "",
                                      style: TextStyle(
                                          fontSize: 3.2.h,
                                          color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0.w),
                                child: !provider
                                        .wordListDbInformation![index].lastCard!
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)
                                                .translate("137"),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: InkWell(
                                                onTap: () async {
                                                  DbProvider db = DbProvider();
                                                  if (provider
                                                          .wordListDbInformation![
                                                              index]
                                                          .isAddedToWorkHard !=
                                                      true) {
                                                    var status = await db
                                                        .addToWorkHardBox(provider
                                                            .wordListDbInformation![
                                                                index]
                                                            .id!);
                                                    if (status == true) {
                                                      setState(() {
                                                        provider
                                                            .wordListDbInformation![
                                                                index]
                                                            .isAddedToWorkHard = true;
                                                      });
                                                    }
                                                  } else {
                                                    //remove
                                                    var status = await db
                                                        .updateWorkHard(provider
                                                            .wordListDbInformation![
                                                                index]
                                                            .id!);
                                                    if (status == true) {
                                                      setState(() {
                                                        provider
                                                            .wordListDbInformation![
                                                                index]
                                                            .isAddedToWorkHard = false;
                                                      });
                                                    }
                                                  }
                                                },
                                                child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 8.0),
                                                    child: Icon(
                                                      provider
                                                                  .wordListDbInformation![
                                                                      index]
                                                                  .isAddedToWorkHard ==
                                                              true
                                                          ? Icons
                                                              .check_circle_outline
                                                          : Icons
                                                              .add_circle_outline_outlined,
                                                      color: provider
                                                                  .wordListDbInformation![
                                                                      index]
                                                                  .isAddedToWorkHard ==
                                                              true
                                                          ? Colors.green
                                                          : Colors.red,
                                                    )),
                                              )),
                                        ],
                                      )
                                    : Container(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    isLoop: false,
                  ),
                  SafeArea(
                    child: Stack(
                      children: [
                        Center(),
                        // TODO: Display a banner when ready
                      ],
                    ),
                  ),
                  if (_bannerAd != null)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: _bannerAd!.size.width.toDouble() * 2,
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                ]
              ],
            );
          })),
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
