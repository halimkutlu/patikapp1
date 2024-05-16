// ignore_for_file: prefer_final_fields, prefer_const_constructors, non_constant_identifier_names, use_build_context_synchronously, prefer_spread_collections, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/api/static_variables.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/models/training_select_names.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/models/word_statistics.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/pages/games/match_moving_square_game.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:patikmobile/services/ad_helper.dart';
import 'package:patikmobile/services/sound_helper.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:sqflite/sqflite.dart';

class MovingSquaresGameProvide extends ChangeNotifier {
  bool? _loading = false;
  bool? get loading => _loading;

  final apirepository = APIRepository();
  final database = Database;
  final int maxRoundCount = 3;

  InterstitialAd? _interstitialAd;
  InterstitialAd get interstitialAd => _interstitialAd!;

  DbProvider db = DbProvider();

  List<Word> comingWordListFromStorage = [];

  bool? _wordsLoaded = false;
  bool? get wordsLoaded => _wordsLoaded;

  bool? _isShuffled = false;
  bool? get isShuffled => _isShuffled;

  int _roundCount = 0;
  int get roundCount => _roundCount;

  set shuffled(bool isShuffled) {
    _isShuffled = isShuffled;
  }

  List<WordListDBInformation>? _wordListDbInformation;
  List<WordListDBInformation>? get wordListDbInformation =>
      _wordListDbInformation;

  List<WordListDBInformation>? _rndWordListDbInformation = [];

  bool? _errorAccuried = false;
  bool? get errorAccuried => _errorAccuried;

  bool? _successAccuried = false;
  bool? get successAccuried => _successAccuried;

  int? _errorCount = 0;
  int? get errorCount => _errorCount;

  int _roundSuccessCount = 0;

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

  int speed = 4;

  //ANTREMAN
  bool isTrainingGame = false;
  int trainingGameIndex = 0;
  List<List<WordListDBInformation>>? _dividedList = [];
  List<WordListDBInformation>? _trainingWordListDbInformation;
  List<WordListDBInformation>? get trainingWordListDbInformation =>
      _trainingWordListDbInformation;

//----
  var diffStatisticWords = [];
  init(
      [BuildContext? context,
      VoidCallback? callback,
      VoidCallback? _callback,
      playWithEnum? playWith,
      bool trainingGame = false]) async {
    if (Platform.isAndroid) {
      speed = 3;
    }
    GameSizeClass().Init();
    _roundCount = 0;
    diffStatisticWords = [];
    _siradaki = 0;
    _errorCount = 0;
    _roundSuccessCount = 0;
    buildContext = context;
    isTrainingGame = trainingGame;
    trainingGameIndex = 0;
    loadAd(closeAd);
    if (!isTrainingGame) {
      await startMatchMovingSquareGame(null);
    } else {
      await startMatchMovingSquareGame(playWith);
    }
    notifyListeners();
    await getWords();
    callback!();
    callback2 = _callback;
  }

  startMatchMovingSquareGame(playWithEnum? playWith) async {
    //1. ADIM ==> Öncelikle bir önceki aşamada seçilen 5 kart local storage üzerinden getirilir.
    if (playWith == null) {
      comingWordListFromStorage = await getSavedWords();
    } else {
      comingWordListFromStorage = await getTrainingWords(playWith);
    }
    //2. ADIM ==> Seçilen kartların db verileri çekilir.
    await getWordsFileInformationFromStorage(comingWordListFromStorage);
    // _selectedWordInfo = _wordListDbInformation![0]; // İlk öğeyi seçelim.
    _wordsLoaded = true;
    notifyListeners();
  }

  getTrainingWords(playWithEnum playWith) async {
    DbProvider dbProvider = DbProvider();
    List<WordStatistics> words = [];
    List<Word> allWords =
        await dbProvider.getWordList(withoutCategoryName: true);
    List<WordStatistics> list = await dbProvider.getWordStatisticsList();

    if (playWith == playWithEnum.learnedWords) {
      words = list.where((wordStat) => wordStat.learned == 1).toList();
    } else if (playWith == playWithEnum.repeatedWords) {
      words = list.where((wordStat) => wordStat.repeat == 1).toList();
    } else if (playWith == playWithEnum.workHardWords) {
      words = list.where((wordStat) => wordStat.workHard == 1).toList();
    } else if (playWith == playWithEnum.allWords) {
      words = list.toList();
    }

    if (words.isNotEmpty) {
      List<Word> result = [];
      for (var wordStat in words) {
        Word? word =
            allWords.where((word) => word.id == wordStat.wordId).firstOrNull;

        if (word != null) {
          result.add(word);
        }
      }
      return result;
    }
  }

  Future<List<Word>> getSavedWords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? serializedWords = prefs.getStringList('selectedWords');
    if (serializedWords != null) {
      var words = serializedWords.map((word) => Word.fromJson(word)).toList();
      return words;
    } else {
      return [];
    }
  }

  getWordsFileInformationFromStorage(List<Word>? selectedCategoryWords) async {
    _wordListDbInformation = [];
    _trainingWordListDbInformation = [];

    String currentLanguage = StorageProvider.learnLanguge!.Code;

    Directory dir = await getApplicationDocumentsDirectory();

    if (selectedCategoryWords!.isNotEmpty) {
      for (var x in selectedCategoryWords) {
        final wordSound =
            '${dir.path}/$currentLanguage/${currentLanguage}_${x.id}.mp3';

        WordListDBInformation wordInfo = WordListDBInformation(
            audio: wordSound,
            word: x.word,
            wordA: x.wordA,
            wordT: x.wordT,
            id: x.id,
            wordAppLng: x.wordAppLng);

        _wordListDbInformation!.add(wordInfo);
        _trainingWordListDbInformation!.add(wordInfo);
      }

      var rndList = await db.getRandomStatisticsWordList(
          limit: 5,
          ignoreIdList: _wordListDbInformation!.map((e) => e.id!).toList());

      for (var x in rndList) {
        WordListDBInformation wordInfo = WordListDBInformation(
            word: x.word,
            wordA: x.wordA,
            wordT: x.wordT,
            id: x.id,
            wordAppLng: x.wordAppLng);

        _rndWordListDbInformation!.add(wordInfo);
      }
    }

    if (isTrainingGame) {
      if (_trainingWordListDbInformation!.length > 5) {
        updateDividedList(_trainingWordListDbInformation!);
        // _trainingIndex kontrolü burada yapılacak
        _wordListDbInformation = _dividedList![trainingGameIndex];

        // displayedList ile yapılacak işlemler devam edecek
      }
    }
  }

  void updateDividedList(List<WordListDBInformation> list) {
    _dividedList = divideListIntoChunks(list, 5);
  }

  List<List<WordListDBInformation>> divideListIntoChunks(
      List<WordListDBInformation> list, int chunkSize) {
    List<List<WordListDBInformation>> dividedList = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      dividedList.add(list.sublist(
          i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return dividedList;
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
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {},
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) => onAdDismissed(),
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

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

  getWords() async {
    if (_wordListDbInformation != null) {
      _currentGameItems = [];
      diffStatisticWords = []
        ..addAll(_wordListDbInformation!)
        ..addAll(_rndWordListDbInformation!);
      for (int i = 0; i < _wordListDbInformation!.length; i++) {
        var differentWord = diffStatisticWords
            .where((element) => element.word != _wordListDbInformation![i].word)
            .elementAt(Random().nextInt(diffStatisticWords.length - 1));

        _currentGameItems!.add(fillGameItem(
            _wordListDbInformation![i].word!,
            differentWord.word!,
            _wordListDbInformation![i].audio,
            _wordListDbInformation![i].id));

        _currentGameItems!.shuffle();
      }
      notifyListeners();
    }
  }

  void moveSquares(BuildContext context,
      [List<AnimationController>? _controllers]) async {
    // PlayAudio(_currentGameItems![_siradaki!].sound);

    if (_siradaki! > _wordListDbInformation!.length - 1) return;
    GameSizeClass.boxEndPosition = (GameSizeClass.bottomMargin -
        ((GameSizeClass.boxSize.height *
                (_siradaki! - _roundSuccessCount + 1)) +
            ((_siradaki! - _roundSuccessCount) * 2.h)));
    //siradaki kutuların konumu değiştiriliyor
    for (int i = 0;
        i < _currentGameItems![_siradaki!].Wordoffsets!.length;
        i++) {
      _currentGameItems![_siradaki!].Wordoffsets![i] = Offset(
          _currentGameItems![_siradaki!].Wordoffsets![i].dx,
          _currentGameItems![_siradaki!].Wordoffsets![i].dy + speed);
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
      if (_siradaki! < _wordListDbInformation!.length) {
        _controllers[_siradaki!].addListener(() {
          moveSquares(context, _controllers);
          notifyListeners();
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          PlayAudio(_currentGameItems![_siradaki!].sound);
          _controllers[_siradaki!].forward();
        });
      } else {
        _roundCount++;
        _roundSuccessCount = 0;
        if (_roundCount < maxRoundCount) {
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
        } else {
          if (!isTrainingGame) {
            _roundCount = 0;
            _roundSuccessCount = 0;
            await FilltheWordsInABox();
            await showSuccessPage(context);
          } else {
            updateDividedList(_trainingWordListDbInformation!);

            trainingGameIndex = trainingGameIndex + 1;
            if (trainingGameIndex == _dividedList!.length) {
              //ANTREMAN BİTMİŞTİR
              Timer(Duration(milliseconds: 100), () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Dashboard(1)),
                    (Route<dynamic> route) => false);
              });
            } else {
              _roundCount = 0;
              _roundSuccessCount = 0;
              _wordListDbInformation = _dividedList![trainingGameIndex];
              _wordsLoaded = true;
              notifyListeners();
              _siradaki = 0;
              await getWords();
              callback2!();
              moveSquares(context, _controllers);
            }
          }
        }

        _isClicked = false;
        notifyListeners();
      }
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

  void boxDown([bool? success = false]) {
    double pplus = 0;
    if (success!) pplus = StaticVariables.AppSize.height * 2;
    _currentGameItems![_siradaki!].Wordoffsets![0] = Offset(
        _currentGameItems![_siradaki!].Wordoffsets![0].dx,
        GameSizeClass.boxEndPosition + pplus);
    _currentGameItems![_siradaki!].Wordoffsets![1] = Offset(
        _currentGameItems![_siradaki!].Wordoffsets![1].dx,
        GameSizeClass.boxEndPosition + pplus);

    notifyListeners();
  }

  Future<void> wrongAnswer(GameItem gameItem, VoidCallback? callback) async {
    _errorAccuried = true;
    notifyListeners();

    Timer(Duration(milliseconds: 500), callback!);
  }

  Future<void> successAnswer(GameItem gameItem, VoidCallback? callback) async {
    _successAccuried = true;
    _roundSuccessCount = _roundSuccessCount + 1;
    notifyListeners();

    Timer(Duration(milliseconds: 500), callback!);
  }

  Future<void> FilltheWordsInABox() async {
    for (var x in comingWordListFromStorage) {
      /*KELİMELER NASIL SINIFLANDIRILACAK? 
 1 kez ve 2 kez hata yaptığı kelimeler ÖĞRENDİM kutusuna eklenecek. 
3 ve 4 kez hata yaptığı kelimeler tekrar et kutusuna eklenecek. 
4ten fazla kez hata yaptığı kelimeler SIKI ÇALIŞ kutusuna eklenecek. */
      if (x.errorCount! >= 0 && x.errorCount! <= 2) {
        await db.addToLearnedBox(x.id!);
      } else if (x.errorCount! >= 3 && x.errorCount! <= 4) {
        await db.addToRepeatBox(x.id!);
      } else {
        await db.addToWorkHardBox(x.id!);
      }
    }
  }

  showSuccessPage(BuildContext context) async {
    await CustomAlertDialogOnlyConfirm(context, () {
      Timer(Duration(milliseconds: 100), () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Dashboard(1)),
            (Route<dynamic> route) => false);
      });
    },
        "",
        AppLocalizations.of(context).translate("154"),
        ArtSweetAlertType.success,
        AppLocalizations.of(context).translate("159"));
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
