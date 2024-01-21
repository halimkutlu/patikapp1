// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:patikmobile/providers/games_providers/swipe_card_game_provider.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';
import 'package:patikmobile/widgets/loading_bar.dart';
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
  bool contentLoaded = false;
  late SwipeCardGameProvider swipeCardProvider;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    swipeCardProvider =
        Provider.of<SwipeCardGameProvider>(context, listen: false);
    swipeCardProvider.init(widget.selectedCategoryInfo, context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        await askToGoMainMenu();
      },
      child: Scaffold(
          backgroundColor: MainColors.backgroundColor,
          body: Consumer<SwipeCardGameProvider>(
              builder: (context, provider, child) {
            return Stack(
              children: [
                if (provider.wordsLoaded == true) ...[
                  CardSwiper(
                    backCardOffset: Offset(-25, -40),
                    cardsCount: provider.wordsLoaded == true
                        ? provider.wordListDbInformation!.length
                        : 1,
                    cardBuilder:
                        (context, index, percentThresholdX, percentThresholdY) {
                      WordListDBInformation cardInfo =
                          provider.wordListDbInformation![index];

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
                              !cardInfo.lastCard!
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            _playAudio(cardInfo.audio);
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
                                    cardInfo.wordA != null
                                        ? cardInfo.wordA!
                                        : "",
                                    style: TextStyle(
                                        fontSize: 2.3.h, color: Colors.black),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(2.0.h),
                                    child: Text(
                                      cardInfo.wordT != null
                                          ? cardInfo.wordT!
                                          : "",
                                      style: TextStyle(
                                          fontSize: 2.3.h,
                                          color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  !cardInfo.lastCard!
                                      ? SvgPicture.memory(
                                          cardInfo.imageUrl!,
                                          height: 19.h,
                                        )
                                      : Container(),
                                  Padding(
                                    padding: EdgeInsets.all(4.0.h),
                                    child: Text(
                                      cardInfo.word!,
                                      style: TextStyle(
                                          fontSize: 3.2.h,
                                          color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0.w),
                                child: !cardInfo.lastCard!
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
                                                  if (cardInfo
                                                          .isAddedToWorkHard !=
                                                      true) {
                                                    var status = await db
                                                        .addToWorkHardBox(
                                                            cardInfo.id!);
                                                    if (status == true) {
                                                      setState(() {
                                                        cardInfo.isAddedToWorkHard =
                                                            true;
                                                      });
                                                    }
                                                  } else {
                                                    //remove
                                                    var status =
                                                        await db.updateWorkHard(
                                                            cardInfo.id!);
                                                    if (status == true) {
                                                      setState(() {
                                                        cardInfo.isAddedToWorkHard =
                                                            false;
                                                      });
                                                    }
                                                  }
                                                },
                                                child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 8.0),
                                                    child: Icon(
                                                      cardInfo.isAddedToWorkHard ==
                                                              true
                                                          ? Icons
                                                              .check_circle_outline
                                                          : Icons
                                                              .add_circle_outline_outlined,
                                                      color:
                                                          cardInfo.isAddedToWorkHard ==
                                                                  true
                                                              ? Colors.green
                                                              : Colors.red,
                                                    )),
                                              ))
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
                ],
                Container(
                    child:
                        provider.wordsLoaded == false ? Loading() : Container())
              ],
            );
          })),
    );
  }

  Future<void> _playAudio(File? audio) async {
    final player = AudioPlayer();

    await player.play(
      UrlSource(audio!.path),
      volume: 500,
    );
  }

  Future<void> askToGoMainMenu() async {
    await CustomAlertDialogOnlyConfirm(context, () {
      Navigator.pop(context);
      Navigator.pop(context);
    },
        "warning".tr,
        "Eğitimi bitirmek istiyormusunuz. Gelişmeleriniz kaydedilmeyecektir.",
        ArtSweetAlertType.info,
        "ok".tr);
  }
}
