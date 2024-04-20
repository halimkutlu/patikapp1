// ignore_for_file: prefer_final_fields, avoid_print, use_build_context_synchronously, unused_local_variable, prefer_const_constructors
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/models/training_select_names.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/models/word_statistics.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/pages/games/multiple_choice_game.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:patikmobile/services/ad_helper.dart';
import 'package:patikmobile/widgets/keyboard_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class FillTheBlankGameProvider extends ChangeNotifier {
  final apirepository = APIRepository();
  final database = Database;

  InterstitialAd? _interstitialAd;
  InterstitialAd? get interstitialAd => _interstitialAd;

  List<Word> comingWordListFromStorage = [];

  bool? _wordsLoaded = false;
  bool? get wordsLoaded => _wordsLoaded;

  List<WordListDBInformation>? _wordListDbInformation;
  List<WordListDBInformation>? get wordListDbInformation =>
      _wordListDbInformation;

  bool? _errorAccuried = false;
  bool? get errorAccuried => _errorAccuried;

  WordListDBInformation? _selectedWord;
  WordListDBInformation? get selectedWord => _selectedWord;

  TextEditingController? _selectedWordTextEditingController =
      TextEditingController();
  TextEditingController? get selectedWordTextEditingController =>
      _selectedWordTextEditingController;
  BuildContext? buildContext;
  int? _errorCount = 0;
  int? get errorCount => _errorCount;

  bool isTrainingGame = false;
  int trainingGameIndex = 0;
  List<List<WordListDBInformation>>? _dividedList = [];
  List<WordListDBInformation>? _trainingWordListDbInformation;
  List<WordListDBInformation>? get trainingWordListDbInformation =>
      _trainingWordListDbInformation;

  init(BuildContext? context, playWithEnum? playWith,
      {bool trainingGame = false}) async {
    trainingGameIndex = 0;
    _selectedWord = null;
    _selectedWordTextEditingController = TextEditingController();
    _errorCount = 0;
    isTrainingGame = trainingGame;
    _wordsLoaded = false;
    buildContext = context;
    loadAd();
    if (!isTrainingGame) {
      await startFillTheBlankGame(null);
    } else {
      await startFillTheBlankGame(playWith);
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

  Future<void> startFillTheBlankGame(playWithEnum? playWith) async {
    //1. ADIM ==> Öncelikle bir önceki aşamada seçilen 5 kart local storage üzerinden getirilir.
    if (playWith == null) {
      comingWordListFromStorage = await getSavedWords();
    } else {
      comingWordListFromStorage = await getTrainingWords(playWith);
    }
    //2. ADIM ==> Seçilen kartların db verileri çekilir.
    await getWordsFileInformationFromStorage(comingWordListFromStorage);
    // _selectedWordInfo = _wordListDbInformation![0]; // İlk öğeyi seçelim.

    if (!isTrainingGame) {
      await takeWord();
    } else {
      startProcedures();
    }
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

  List<WordListDBInformation> usedWords = [];
  Future<void> takeWord() async {
    _selectedWord = null;
    _selectedWordTextEditingController = TextEditingController();
    _errorCount = 0;
    _wordsLoaded = false;
    WordListDBInformation? takenWord;
    WordListDBInformation word = WordListDBInformation();
    if (_wordListDbInformation!.isNotEmpty) {
      print(_selectedWord);
      _selectedWord = _wordListDbInformation!.removeAt(0);
      // _selectedWordTextEditingController!.text = _selectedWord!.word!;
      print(_selectedWord);
      _wordsLoaded = true;

      trainingGameIndex = trainingGameIndex + 1;
    } else {
      //oyun bitmiştir
      if (!isTrainingGame) {
        goToNextGame(buildContext!);
        print("TEBRİKLER");
      } else {
        //ANTREMAN BİTMİŞTİR
        Timer(Duration(milliseconds: 100), () {
          Navigator.of(buildContext!).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => Dashboard(1)),
              (Route<dynamic> route) => false);
        });
      }
    }
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

  void resetData() {
    _wordsLoaded = false;
    _wordListDbInformation = [];
    _selectedWordTextEditingController = TextEditingController();
    _selectedWord = null;
  }

  getWordsFileInformationFromStorage(List<Word>? selectedCategoryWords) async {
    _wordListDbInformation = [];
    _trainingWordListDbInformation = [];

    String currentLanguage = StorageProvider.learnLanguge!.Code;

    Directory dir = await getApplicationDocumentsDirectory();

    if (selectedCategoryWords!.isNotEmpty) {
      for (var x in selectedCategoryWords) {
        final wordImage = await File(
                '${dir.path}/$currentLanguage/${currentLanguage}_${x.id}.svg')
            .readAsBytes();
        WordListDBInformation wordInfo = WordListDBInformation(
            imageBytes: wordImage,
            word: x.word,
            wordA: x.wordA,
            wordT: x.wordT,
            id: x.id);

        _wordListDbInformation!.add(wordInfo);
        _trainingWordListDbInformation!.add(wordInfo);
      }
    }
    if (isTrainingGame) {
      _wordListDbInformation = _trainingWordListDbInformation;
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

  void goToNextGame(BuildContext context) {
    if (!isTrainingGame) {
      resetData();

      saveSelectedWords();
      Timer(Duration(milliseconds: 100), () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MultipleChoiceGame()),
            (Route<dynamic> route) => false);
      });
    } else {
      resetData();
      if (trainingGameIndex == _dividedList!.length) {
        //ANTREMAN BİTMİŞTİR
        Timer(Duration(milliseconds: 100), () {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => Dashboard(1)),
              (Route<dynamic> route) => false);
        });
      } else {
        _wordListDbInformation = _dividedList![trainingGameIndex];
      }
      _wordsLoaded = true;
      notifyListeners();
    }
  }

  Future<void> wrongCharacter() async {
    _errorAccuried = true;
    notifyListeners();

    Timer(Duration(seconds: 1), () async {
      var word = comingWordListFromStorage
          .firstWhere((element) => element.id == _selectedWord!.id);
      word.errorCount = word.errorCount! + 1;

      _errorCount = _errorCount! + 1;

      if (_errorCount! > 3) {
        if (_interstitialAd != null) {
          await loadAd();
          _errorCount = 0;
          _interstitialAd?.show();

          //REKLAM GÖSTER6
        }
      }
      _errorAccuried = false;
      notifyListeners();
    });
  }

  bool processDone = false;
  late int buttonCount = 25;
  late List<KeyCharInformation> keyList = [];
  late Map<String, int> wordCharList = <String, int>{};

  String? _word = "";
  String? get word => _word;

  Uint8List? _image = Uint8List(0);
  Uint8List? get image => _image;

  void startProcedures() async {
    _selectedWordTextEditingController = TextEditingController();
    wordCharList = <String, int>{};
    keyList = [];
    processDone = false;
    await takeWord();
    if (_selectedWord != null) {
      _image = _selectedWord!.imageBytes;
      _word = _selectedWord!.word;
      final clearWord = word?.replaceAll(" ", "");

      List<String>.generate(clearWord!.length, (index) => clearWord[index])
          .forEach((x) => wordCharList[x] =
              !wordCharList.containsKey(x) ? 1 : (wordCharList[x]! + 1));

      keyList = Iterable<int>.generate(buttonCount)
          .toList()
          .map((r) => KeyCharInformation(r, 0, ''))
          .toList();

      wordCharList.forEach((key, value) {
        var list = keyList.where((element) => element.Count == 0).toList();
        if (list.isNotEmpty) {
          KeyCharInformation keyButton =
              (keyList.where((element) => element.Count == 0).toList()
                    ..shuffle())
                  .first;
          if (keyButton != null) {
            keyButton.Char = key;
            keyButton.Count = value;
          }
        }
      });
      processDone = true;
    }
    notifyListeners();
  }
  // }
}
