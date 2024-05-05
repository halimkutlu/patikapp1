// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_init_to_null

import 'dart:async';
import 'dart:io';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:patikmobile/providers/games_providers/swipe_card_game_provider.dart';
import 'package:patikmobile/services/ad_helper.dart';
import 'package:patikmobile/services/image_helper.dart';
import 'package:patikmobile/services/sound_helper.dart';
import 'package:patikmobile/widgets/customAlertDialog.dart';
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
  bool firstLoad = true;
  late SwipeCardGameProvider swipeCardProvider;
  BannerAd? _bannerAd;
  late AdProvider adProvider;

  @override
  void initState() {
    super.initState();
    swipeCardProvider =
        Provider.of<SwipeCardGameProvider>(context, listen: false);
    swipeCardProvider.init(widget.selectedCategoryInfo, context);

    adProvider = Provider.of<AdProvider>(context, listen: false);
    adProvider.init(context, (ad) {
      setState(() => _bannerAd = ad);
    });
  }

  @override
  void dispose() {
    if (_bannerAd != null) _bannerAd!.dispose();
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
            swipeCardProvider.resetData();
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
                      await askToGoMainMenu(context, func: () {
                        setState(() {
                          swipeCardProvider.resetData();
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
          body: Consumer<SwipeCardGameProvider>(
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
                if (provider.wordsLoaded == true) ...[
                  CardSwiper(
                    onSwipe: (oncekiIndex, index, direction) {
                      if (index != null && index > 0) {
                        PlayAudio(provider.wordListDbInformation![index].audio);
                      }
                      return true;
                    },
                    onEnd: () {
                      provider.goToNextGame(context);
                    },
                    backCardOffset: Offset(-25, -40),
                    cardsCount: provider.wordsLoaded == true
                        ? provider.wordListDbInformation!.length
                        : 1,
                    cardBuilder:
                        (context, index, percentThresholdX, percentThresholdY) {
                      if (firstLoad) {
                        firstLoad = false;
                        PlayAudio(provider.wordListDbInformation![0].audio);
                      }
                      return Center(
                        child: Container(
                          height: 71.h,
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
                                      ? getWordImage(
                                          provider
                                              .wordListDbInformation![index].id
                                              .toString(),
                                          false,
                                          height: 19.h)
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
                              // Padding(
                              //   padding: EdgeInsets.all(8.0.w),
                              //   child: !provider
                              //           .wordListDbInformation![index].lastCard!
                              //       ? Row(
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.end,
                              //           children: [
                              //             AutoSizeText(
                              //               maxLines: 2,
                              //               AppLocalizations.of(context)
                              //                   .translate("137"),
                              //             ),
                              //             Padding(
                              //                 padding: EdgeInsets.all(8.0),
                              //                 child: InkWell(
                              //                   onTap: () async {
                              //                     DbProvider db = DbProvider();
                              //                     if (provider
                              //                             .wordListDbInformation![
                              //                                 index]
                              //                             .isAddedToWorkHard !=
                              //                         true) {
                              //                       var status = await db
                              //                           .addToWorkHardBox(provider
                              //                               .wordListDbInformation![
                              //                                   index]
                              //                               .id!);
                              //                       if (status == true) {
                              //                         setState(() {
                              //                           provider
                              //                               .wordListDbInformation![
                              //                                   index]
                              //                               .isAddedToWorkHard = true;
                              //                         });
                              //                       }
                              //                     } else {
                              //                       //remove
                              //                       var status = await db
                              //                           .updateWorkHard(provider
                              //                               .wordListDbInformation![
                              //                                   index]
                              //                               .id!);
                              //                       if (status == true) {
                              //                         setState(() {
                              //                           provider
                              //                               .wordListDbInformation![
                              //                                   index]
                              //                               .isAddedToWorkHard = false;
                              //                         });
                              //                       }
                              //                     }
                              //                   },
                              //                   child: Padding(
                              //                       padding: EdgeInsets.only(
                              //                           left: 8.0),
                              //                       child: Icon(
                              //                         provider
                              //                                     .wordListDbInformation![
                              //                                         index]
                              //                                     .isAddedToWorkHard ==
                              //                                 true
                              //                             ? Icons
                              //                                 .check_circle_outline
                              //                             : Icons
                              //                                 .add_circle_outline_outlined,
                              //                         color: provider
                              //                                     .wordListDbInformation![
                              //                                         index]
                              //                                     .isAddedToWorkHard ==
                              //                                 true
                              //                             ? Colors.green
                              //                             : Colors.red,
                              //                       )),
                              //                 )),
                              //           ],
                              //         )
                              //       : Container(),
                              // ),
                            ],
                          ),
                        ),
                      );
                    },
                    isLoop: false,
                  )
                ]
              ],
            );
          })),
    );
  }
}
