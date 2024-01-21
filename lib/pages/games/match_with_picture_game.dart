// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/providers/games_providers/match_with_picture_game_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class MatchWithPictureGame extends StatefulWidget {
  const MatchWithPictureGame({super.key});

  @override
  State<MatchWithPictureGame> createState() => _MatchWithPictureGameState();
}

class _MatchWithPictureGameState extends State<MatchWithPictureGame> {
  late MatchWithPictureGameProvide matchWithPictureGameProvide;

  @override
  void initState() {
    super.initState();
    matchWithPictureGameProvide =
        Provider.of<MatchWithPictureGameProvide>(context, listen: false);
    matchWithPictureGameProvide.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainColors.backgroundColor,
      body: Consumer<MatchWithPictureGameProvide>(
        builder: (context, provider, child) {
          List<WordListDBInformation> imageList = [];
          List<WordListDBInformation> wordList = [];
          if (!provider.wordsLoaded!) {
            // Eğer kelimeler yüklenmediyse bir yükleniyor ekranı göster
            return Center(child: CircularProgressIndicator());
          } else {
            imageList = List.from(provider.wordListDbInformation!);
            wordList = List.from(provider.wordListDbInformation!);

            imageList.shuffle(Random(5));
            wordList.shuffle(Random(9));
          }
          return Stack(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: _buildImageWidgets(imageList, provider),
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
                Expanded(flex: 3, child: ErrorImage()),
              ]
            ],
          );
        },
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
                  provider.selectImage(info);
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
              info.imageUrl!,
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
                  provider.selectWord(info);
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
}
