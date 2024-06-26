// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/models/training_select_names.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/providers/games_providers/match_with_sound_game_provider.dart';
import 'package:patikmobile/services/ad_helper.dart';
import 'package:patikmobile/services/sound_helper.dart';
import 'package:patikmobile/widgets/customAlertDialog.dart';
import 'package:patikmobile/widgets/error_image.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class MatchWithSoundGame extends StatefulWidget {
  final bool? trainingGame;
  final playWithEnum? playWith;
  const MatchWithSoundGame(
      {super.key, this.trainingGame = false, this.playWith});

  @override
  State<MatchWithSoundGame> createState() => _MatchWithSoundGameState();
}

class _MatchWithSoundGameState extends State<MatchWithSoundGame> {
  BannerAd? _bannerAd;

  late MatchWithSoundGameProvide matchWithSoundGameProvide;
  late AdProvider adProvider;

  @override
  void initState() {
    super.initState();
    matchWithSoundGameProvide =
        Provider.of<MatchWithSoundGameProvide>(context, listen: false);
    matchWithSoundGameProvide.init(context, widget.playWith,
        trainingGame: widget.trainingGame!);

    adProvider = Provider.of<AdProvider>(context, listen: false);
    adProvider.init(context, (ad) {
      setState(() => _bannerAd = ad);
    });
  }

  @override
  void dispose() {
    if (_bannerAd != null) _bannerAd!.dispose();
    if (matchWithSoundGameProvide.interstitialAd != null) {
      matchWithSoundGameProvide.interstitialAd!.dispose();
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
            matchWithSoundGameProvide.resetData();
            matchWithSoundGameProvide.setUISound = [];
            matchWithSoundGameProvide.setUIWord = [];
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
                        matchWithSoundGameProvide.resetData();
                        matchWithSoundGameProvide.setUISound = [];
                        matchWithSoundGameProvide.setUIWord = [];
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
        body: Consumer<MatchWithSoundGameProvide>(
          builder: (context, provider, child) {
            if (!provider.wordsLoaded!) {
              // Eğer kelimeler yüklenmediyse bir yükleniyor ekranı göster
              return Center(child: CircularProgressIndicator());
            } else if (matchWithSoundGameProvide.UIsoundList.isEmpty ||
                matchWithSoundGameProvide.UIwordList.isEmpty) {
              matchWithSoundGameProvide.setUISound =
                  List.from(provider.wordListDbInformation!);
              matchWithSoundGameProvide.setUIWord =
                  List.from(provider.wordListDbInformation!);
              matchWithSoundGameProvide.UIsoundList.shuffle();
              matchWithSoundGameProvide.UIwordList.shuffle();
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
                            children: _buildSoundWidgets(
                                matchWithSoundGameProvide.UIsoundList,
                                provider),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: _buildWordWidgets(
                                matchWithSoundGameProvide.UIwordList, provider),
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
}
