// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/providers/games_providers/swipe_card_game_provider.dart';
import 'package:patikmobile/widgets/loading_bar.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';

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

    // setState(() {
    //   swipeCardProvider.init();
    // });
    // swipeCardGameProvider = SwipeCardGameProvider();

    // WidgetsBinding.instance.addPostFrameCallback(
    //     (_) => swipeCardGameProvider.init(widget.selectedCategoryInfo));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MainColors.backgroundColor,
        body: Consumer<SwipeCardGameProvider>(
            builder: (context, provider, child) {
          return provider.wordsLoaded == true
              ? CardSwiper(
                  backCardOffset: Offset(-25, -40),
                  cardsCount: provider.wordsLoaded == true
                      ? provider.wordListDbInformation!.length
                      : 0,
                  cardBuilder:
                      (context, index, percentThresholdX, percentThresholdY) {
                    WordListDBInformation cardInfo =
                        provider.wordListDbInformation![index];

                    // File nesnesinden dosya yolunu al
                    String imagePath = cardInfo.imageUrl!.path;

                    return Center(
                      child: Container(
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: MainColors.primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                          border: Border.all(width: 0.2),
                        ),
                        alignment: new Alignment(0, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
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
                            ),
                            Column(
                              children: [
                                Text(
                                  cardInfo.word != null ? cardInfo.word! : "",
                                  style: TextStyle(
                                      fontSize: 2.3.h, color: Colors.black),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(2.0.h),
                                  child: Text(
                                    cardInfo.word != null ? cardInfo.word! : "",
                                    style: TextStyle(
                                        fontSize: 2.3.h, color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                SvgPicture.file(
                                  cardInfo.imageUrl!,
                                  height: 19.h,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(4.0.h),
                                  child: Text(
                                    cardInfo.word!,
                                    style: TextStyle(
                                        fontSize: 3.2.h, color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate("137"),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Icon(
                                        Icons.add_circle_outline_outlined,
                                        color: Colors.red,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  isLoop: false,
                )
              : Center(
                  child: Loading(),
                );
        }));
  }

  Future<File> _getLocalFile(File file) async {
    return file;
  }

  Future<void> _playAudio(File? audio) async {
    final player = AudioPlayer();

    await player.play(
      UrlSource(audio!.path),
      volume: 300,
    );
  }
}
