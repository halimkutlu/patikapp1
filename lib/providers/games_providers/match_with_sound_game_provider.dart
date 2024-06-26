// ignore_for_file: prefer_final_fields, avoid_print, use_build_context_synchronously, unused_local_variable, prefer_const_constructors, non_constant_identifier_names
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/models/training_select_names.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/models/word_statistics.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/pages/games/fill_the_blank_game.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:patikmobile/services/ad_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class MatchWithSoundGameProvide extends ChangeNotifier {
  final apirepository = APIRepository();
  final database = Database;

  InterstitialAd? _interstitialAd;
  InterstitialAd? get interstitialAd => _interstitialAd;

  List<Word> comingWordListFromStorage = [];

  bool? _wordsLoaded = false;
  bool? get wordsLoaded => _wordsLoaded;

  bool? _isShuffled = false;
  bool? get isShuffled => _isShuffled;

  set shuffled(bool isShuffled) {
    _isShuffled = isShuffled;
  }

  List<Word>? _selectedCategoryWords;
  List<Word>? get selectedCategoryWords => _selectedCategoryWords;

  List<WordListDBInformation>? _wordListDbInformation;
  List<WordListDBInformation>? get wordListDbInformation =>
      _wordListDbInformation;

  WordListDBInformation? _selectedWordInfo;
  WordListDBInformation? get selectedWordInfo => _selectedWordInfo;

  WordListDBInformation? _listenedSound;
  WordListDBInformation? get listenedSound => _listenedSound;

  bool? _errorAccuried = false;
  bool? get errorAccuried => _errorAccuried;

  int? _errorCount = 0;
  int? get errorCount => _errorCount;

  //antreman için buraya taşıdım
  List<WordListDBInformation> _UISoundList = [];
  List<WordListDBInformation> _UIwordList = [];

  List<WordListDBInformation> get UIsoundList => _UISoundList;
  List<WordListDBInformation> get UIwordList => _UIwordList;

  set setUISound(List<WordListDBInformation> list) {
    _UISoundList = list;
  }

  set setUIWord(List<WordListDBInformation> list) {
    _UIwordList = list;
  }

//--
  bool isTrainingGame = false;
  int trainingGameIndex = 0;
  List<List<WordListDBInformation>>? _dividedList = [];
  List<WordListDBInformation>? _trainingWordListDbInformation;
  List<WordListDBInformation>? get trainingWordListDbInformation =>
      _trainingWordListDbInformation;

  init(BuildContext? context, playWithEnum? playWith,
      {bool trainingGame = false}) async {
    _isShuffled = false;
    isTrainingGame = trainingGame;
    _errorCount = 0;
    loadAd();
    trainingGameIndex = 0;
    if (!trainingGame) {
      await startMatchWithSoundGame(null);
    } else {
      await startMatchWithSoundGame(playWith);
    }
  }

  Future<void> loadAd() async {
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
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                },
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

  Future<void> startMatchWithSoundGame(playWithEnum? playWith) async {
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

  Future<void> saveSelectedWords(List<Word> selectedWords) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> serializedWords =
        selectedWords.map((word) => word.toJson()).toList();
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

  void resetData() {
    _wordsLoaded = false;
    _wordListDbInformation = [];
    _listenedSound = null;
    _selectedWordInfo = null;
    _UISoundList = [];
    _UIwordList = [];
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
            id: x.id);

        _wordListDbInformation!.add(wordInfo);
        _trainingWordListDbInformation!.add(wordInfo);
      }
    }

    if (isTrainingGame) {
      if (_trainingWordListDbInformation!.length > 5) {
        updateDividedList(_trainingWordListDbInformation!);
        // _trainingIndex kontrolü burada yapılacak
        _wordListDbInformation = _dividedList![trainingGameIndex];

        trainingGameIndex = trainingGameIndex + 1;
        // displayedList ile yapılacak işlemler devam edecek
      } else {
        trainingGameIndex = trainingGameIndex + 1;
      }
    }
    print(_wordListDbInformation);
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

  void selectSound(WordListDBInformation selectedInfo) {
    _listenedSound = selectedInfo;
    print(_listenedSound);
    selectedInfo.isSoundListened = true;
    notifyListeners();
  }

  void resetSelectSound(WordListDBInformation info) {
    resetSelections();
  }

  void selectWord(WordListDBInformation selectedInfo, BuildContext context) {
    if (_listenedSound != null && (selectedInfo.isWordCorrect != true)) {
      _selectedWordInfo = selectedInfo;
      print(_selectedWordInfo);
      selectedInfo.isWordSelected = true;
      notifyListeners();

      checkMatch();
      print(_wordListDbInformation);
      if (!_wordListDbInformation!.any((element) =>
          element.isWordCorrect == null || element.isWordCorrect == false)) {
        goToNextGame(context);
      }
    }
  }

  void goToNextGame(BuildContext context) {
    if (!isTrainingGame) {
      resetData();

      Timer(Duration(milliseconds: 100), () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => FillTheBlankGame()),
            (Route<dynamic> route) => false);
      });
    } else {
      resetData();
      notifyListeners();

      updateDividedList(_trainingWordListDbInformation!);
      if (trainingGameIndex == _dividedList!.length) {
        //ANTREMAN BİTMİŞTİR
        Timer(Duration(milliseconds: 100), () {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => Dashboard(1)),
              (Route<dynamic> route) => false);
        });
      } else {
        _wordListDbInformation = _dividedList![trainingGameIndex];

        trainingGameIndex = trainingGameIndex + 1;
      }
      _wordsLoaded = true;
      notifyListeners();
    }
  }

  bool checkMatch() {
    if (_listenedSound != null && _selectedWordInfo != null) {
      if (_listenedSound!.word == _selectedWordInfo!.word) {
        _selectedWordInfo!.isWordCorrect = true;
        _listenedSound!.isSoundCorrect = true;

        _selectedWordInfo!.isSoundListened = false;
        _selectedWordInfo!.isWordSelected = false;

        //seçimler temizlenir
        _listenedSound = null;
        _selectedWordInfo = null;
        //----
        notifyListeners();

        return true;
      } else {
        _listenedSound!.isSoundCorrect = false;
        _selectedWordInfo!.isWordCorrect = false;

        _selectedWordInfo!.isSoundListened = false;
        _selectedWordInfo!.isWordSelected = false;

        _errorAccuried = true;
        notifyListeners();

        Timer(Duration(seconds: 1), () {
          resetSelections();
        });
        return false;
      }
    }
    return false;
  }

  void resetSelections() async {
    if (!isTrainingGame) {
      var word = comingWordListFromStorage
          .firstWhere((element) => element.id == _listenedSound!.id);
      word.errorCount = word.errorCount! + 1;
    }

    _errorCount = _errorCount! + 1;
    _listenedSound!.isSoundCorrect = null;

    if (_selectedWordInfo != null) {
      _selectedWordInfo!.isWordCorrect = null;

      _selectedWordInfo!.isSoundListened = false;
      _selectedWordInfo!.isWordSelected = null;
    }

    _wordListDbInformation?.forEach(
      (element) {
        element.isWordSelected = false;
        element.isSoundListened = false;
      },
    );

    //seçimler temizlenir
    _listenedSound = null;
    _selectedWordInfo = null;
    _errorAccuried = false;
    //----
    notifyListeners();

    if (_errorCount! > 3) {
      if (_interstitialAd != null) {
        await loadAd();
        _errorCount = 0;
        _interstitialAd?.show();

        //REKLAM GÖSTER6
      }
    }
  }

  getTrainingWords(playWithEnum playWith) async {
    LearnDbProvider dbProvider = LearnDbProvider();
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
}
