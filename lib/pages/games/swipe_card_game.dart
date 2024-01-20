import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/providers/games_providers/swipe_card_game_provider.dart';
import 'package:patikmobile/widgets/loading_bar.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class SwipeCardGame extends StatefulWidget {
  final WordListInformation? selectedCategoryInfo;
  const SwipeCardGame({super.key, this.selectedCategoryInfo});

  @override
  State<SwipeCardGame> createState() => _SwipeCardGameState();
}

class _SwipeCardGameState extends State<SwipeCardGame> {
  bool contentLoaded = false;
  late SwipeCardGameProvider swipeCardProvider;

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
                  numberOfCardsDisplayed: 3,
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FutureBuilder(
                              future: _getLocalFile(cardInfo.imageUrl!),
                              builder: (BuildContext context,
                                  AsyncSnapshot<File> snapshot) {
                                return snapshot.data != null &&
                                        snapshot.data!.existsSync()
                                    ? Image.file(snapshot.data!)
                                    : Container(); // Handle non-existent file
                              },
                            ),
                            Text(cardInfo.word!),
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
}
