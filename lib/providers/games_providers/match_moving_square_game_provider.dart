// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/pages/games/match_moving_square_game.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:patikmobile/services/ad_helper.dart';
import 'package:patikmobile/services/sound_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:sqflite/sqflite.dart';

class MovingSquaresGameProvide extends ChangeNotifier {
  bool? _loading = false;
  bool? get loading => _loading;

  final apirepository = APIRepository();
  final database = Database;

  InterstitialAd? _interstitialAd;
  InterstitialAd get interstitialAd => _interstitialAd!;

  List<Word> comingWordListFromStorage = [];

  bool? _wordsLoaded = false;
  bool? get wordsLoaded => _wordsLoaded;

  bool? _isShuffled = false;
  bool? get isShuffled => _isShuffled;

  int? _roundName = 1;
  int? get roundName => _roundName;

  set shuffled(bool isShuffled) {
    _isShuffled = isShuffled;
  }

  List<WordListDBInformation>? _wordListDbInformation;
  List<WordListDBInformation>? get wordListDbInformation =>
      _wordListDbInformation;

  List<WordListDBInformation>? _wordListPool;
  List<WordListDBInformation>? get wordListPool => _wordListPool;

  bool? _errorAccuried = false;
  bool? get errorAccuried => _errorAccuried;

  bool? _successAccuried = false;
  bool? get successAccuried => _successAccuried;

  int? _errorCount = 0;
  int? get errorCount => _errorCount;

  int? _siradaki = 0;
  int? get siradaki => _siradaki;

  bool? _isClicked = false;
  bool? get isClicked => _isClicked;

  set setIsClicked(bool clicked) {
    _isClicked = clicked;
  }

  set setErrorAccuried(bool error) {
    _errorAccuried = error;
  }

  set setSuccessAccuried(bool success) {
    _successAccuried = success;
  }

  WordListDBInformation? _selectedWord;
  WordListDBInformation? get selectedWord => _selectedWord;

  List<GameItem>? _currentGameItems = [];
  List<GameItem>? get currentGameItems => _currentGameItems;

  BuildContext? buildContext;

  VoidCallback? callback2;

  init(
      [BuildContext? context,
      VoidCallback? callback,
      VoidCallback? _callback]) async {
    GameSizeClass().Init();

    _siradaki = 0;
    _errorCount = 0;
    buildContext = context;
    loadAd(closeAd);
    await startMatchMovingSquareGame();
    notifyListeners();
    await getWords();
    callback!();
    callback2 = _callback;
  }

  startMatchMovingSquareGame() async {
    //1. ADIM ==> Öncelikle bir önceki aşamada seçilen 5 kart local storage üzerinden getirilir.
    comingWordListFromStorage = await getSavedWords();
    //2. ADIM ==> Seçilen kartların db verileri çekilir.
    await getWordsFileInformationFromStorage(comingWordListFromStorage);
    // _selectedWordInfo = _wordListDbInformation![0]; // İlk öğeyi seçelim.
    _wordsLoaded = true;
    notifyListeners();
  }

  Future<void> saveSelectedWords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> serializedWords =
        comingWordListFromStorage.map((word) => word.toJson()).toList();
    prefs.setStringList('selectedWords', serializedWords);
    print('Selected words saved to SharedPreferences');
  }

  Future<List<Word>> getSavedWords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? serializedWords = prefs.getStringList('selectedWords');
    if (serializedWords != null) {
      var words = serializedWords.map((word) => Word.fromJson(word)).toList();
      print(words);
      return words;
    } else {
      return [];
    }
  }

  Future<String> getCurrentLanguageAsString() async {
    int? language;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    language = prefs.getInt(StorageProvider.learnLcidKey);
    if (language != null) {
      Lcid lcid = Languages.GetLngFromLCID(language);
      return lcid.Code;
    }

    return "";
  }

  getWordsFileInformationFromStorage(List<Word>? selectedCategoryWords) async {
    _wordListDbInformation = [];
    _wordListPool = [];
    String currentLanguage = await getCurrentLanguageAsString();

    Directory dir = await getApplicationDocumentsDirectory();

    if (selectedCategoryWords!.isNotEmpty) {
      for (var x in selectedCategoryWords) {
        final wordImage = await File(
                '${dir.path}/$currentLanguage/${currentLanguage}_${x.id}.svg')
            .readAsBytes();
        final wordSound =
            '${dir.path}/$currentLanguage/${currentLanguage}_${x.id}.mp3';

        WordListDBInformation wordInfo = WordListDBInformation(
            audio: wordSound,
            imageBytes: wordImage,
            word: x.word,
            wordA: x.wordA,
            wordT: x.wordT,
            id: x.id,
            wordAppLng: x.wordAppLng);

        _wordListDbInformation!.add(wordInfo);
        _wordListPool!.add(wordInfo);
      }
    }
    print(_wordListDbInformation);
  }

  Future<void> loadAd(VoidCallback onAdDismissed) async {
    InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {
              print("object");
            },
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {
              print("object");
            },
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
              print("object");
              // Dispose the ad here to free resources.
            },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
              if (onAdDismissed != null) {
                onAdDismissed();
              }
            },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {
              print("object");
            });

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  GameItem fillGameItem(
      String trueWord, String wrongWord, String? audio, int? wordId) {
    GameItem? item = GameItem();
    item.words = [];
    item.Wordoffsets = [];
    item.wordId = wordId;
    List<String> random = [trueWord, wrongWord];
    var word = random[Random().nextInt(2)];

    item.Wordoffsets = [
      Offset(GameSizeClass.firstBoxOffset, -13.h),
      Offset(GameSizeClass.secondBoxOffset, -13.h),
    ];
    item.words!.add(word);

    item.sound = audio!;
    item.words!.add(word == trueWord ? wrongWord : trueWord);
    item.trueIndex = item.words!
        .indexOf(random.firstWhere((element) => trueWord == element));
    return item;
  }

  getWords() {
    if (_wordListDbInformation != null && _wordListPool != null) {
      _currentGameItems = [];

      for (int i = 0; i < _wordListDbInformation!.length; i++) {
        var differentWord = _wordListPool!.firstWhere(
          (element) => element.word != _wordListDbInformation![i].word,
          orElse: () => _wordListPool!.first,
        );

        _currentGameItems!.add(fillGameItem(
            _wordListDbInformation![i].word!,
            differentWord.word!,
            _wordListDbInformation![i].audio,
            _wordListDbInformation![i].id));
      }
      notifyListeners();
    }
  }

  void moveSquares([List<AnimationController>? _controllers]) {
    // PlayAudio(_currentGameItems![_siradaki!].sound);

    if (_siradaki! > 4) return;
    GameSizeClass.boxEndPosition = (GameSizeClass.bottomMargin -
        ((GameSizeClass.boxSize * (_siradaki! + 1)) + (_siradaki! * 2.h)));
    //siradaki kutuların konumu değiştiriliyor
    for (int i = 0;
        i < _currentGameItems![_siradaki!].Wordoffsets!.length;
        i++) {
      _currentGameItems![_siradaki!].Wordoffsets![i] = Offset(
          _currentGameItems![_siradaki!].Wordoffsets![i].dx,
          _currentGameItems![_siradaki!].Wordoffsets![i].dy + 2);
    }
    //siradaki kutular belirlenen konuma geldiğinde bağlı animasyon dispose edilip varsa sıradaki çalıştırılıyor
    if (_currentGameItems![_siradaki!].Wordoffsets![0].dy >=
        GameSizeClass.boxEndPosition) {
      if (_isClicked == false) {
        _errorCount = _errorCount! + 1;
      }
      _controllers![_siradaki!].stop();
      // _controllers[siradaki].dispose();
      // sonraki animasyona geçiliyor
      _siradaki = _siradaki! + 1;
      // sonuncu animasyondan sonra tekrar girmiyor
      if (_siradaki! < 5) {
        _controllers![_siradaki!].addListener(() {
          moveSquares(_controllers);
          notifyListeners();
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          PlayAudio(_currentGameItems![_siradaki!].sound);
          _controllers[_siradaki!].forward();
        });
      } else {
        //yeni oyun başlar.

        if (_errorCount! > 3) {
          if (_interstitialAd != null) {
            _interstitialAd?.show();
            _errorCount = 0;
          } else {
            closeAd();
          }
        } else {
          closeAd();
        }
      }

      _isClicked = false;
      notifyListeners();
    }
  }

  void closeAd() {
    loadAd(closeAd);
    getWords();
    _siradaki = 0;
    callback2!();
    notifyListeners();
  }

  void countError(GameItem gameItem) {
    var word = comingWordListFromStorage
        // ignore: unrelated_type_equality_checks
        .firstWhere((element) => element.id == gameItem.wordId);
    word.errorCount = word.errorCount! + 1;

    _errorCount = _errorCount! + 1;
  }

  void resetSelections(VoidCallback addCallback) async {}

  void boxDown() {
    _currentGameItems![_siradaki!].Wordoffsets![0] = Offset(
        _currentGameItems![_siradaki!].Wordoffsets![0].dx,
        GameSizeClass.boxEndPosition);
    _currentGameItems![_siradaki!].Wordoffsets![1] = Offset(
        _currentGameItems![_siradaki!].Wordoffsets![1].dx,
        GameSizeClass.boxEndPosition);

    notifyListeners();
  }

  Future<void> wrongAnswer(GameItem gameItem, VoidCallback? callback) async {
    _errorAccuried = true;
    notifyListeners();

    Timer(Duration(seconds: 1), callback!);
  }

  Future<void> successAnswer(GameItem gameItem, VoidCallback? callback) async {
    _successAccuried = true;
    notifyListeners();

    Timer(Duration(seconds: 1), callback!);
  }
}

class GameItem {
  late int? trueIndex;
  late List<Offset>? Wordoffsets = [];
  late List<String>? words = [];
  late String? sound;
  late int? wordId;

  GameItem(
      {this.wordId, this.trueIndex, this.Wordoffsets, this.words, this.sound});
}
