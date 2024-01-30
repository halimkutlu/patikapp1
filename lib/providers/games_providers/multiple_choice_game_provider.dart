// ignore_for_file: prefer_final_fields, avoid_print, use_build_context_synchronously, unused_local_variable, prefer_const_constructors
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:patikmobile/services/ad_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class MultipleChoiceGameProvider extends ChangeNotifier {
  final apirepository = APIRepository();
  final database = Database;

  InterstitialAd? _interstitialAd;
  InterstitialAd get interstitialAd => _interstitialAd!;

  List<Word> comingWordListFromStorage = [];

  bool? _wordsLoaded = false;
  bool? get wordsLoaded => _wordsLoaded;

  bool? _isShuffled = false;
  bool? get isShuffled => _isShuffled;

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

  WordListDBInformation? _selectedWord;
  WordListDBInformation? get selectedWord => _selectedWord;

  List<GameAnswerModel>? _selectedAnswerList = [];
  List<GameAnswerModel>? get selectedAnswerList => _selectedAnswerList;

  BuildContext? buildContext;

  init([BuildContext? context]) async {
    _errorCount = 0;
    buildContext = context;
    loadAd();
    await startMultipleChoiceGame();
    await takeWord();
    notifyListeners();
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

  Future<void> startMultipleChoiceGame() async {
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

  void resetData() {
    _wordsLoaded = false;
    _wordListDbInformation = [];
    _selectedAnswerList = [];
    _selectedWord = null;
    _successAccuried = false;
    _errorAccuried = false;
    _wordListPool = [];
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

  void goToNextGame(BuildContext context) {
    resetData();
    saveSelectedWords();
    Timer(Duration(milliseconds: 100), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Dashboard(0)),
          (Route<dynamic> route) => false);
    });
  }

  Future<void> takeWord() async {
    _selectedWord = null;
    _selectedAnswerList = [];
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
      await takeAnswers(_selectedWord);
    } else {
      //oyun bitmiştir
      goToNextGame(buildContext!);
      print("TEBRİKLER");
    }
  }

  Future<void> takeAnswers(WordListDBInformation? selectedWord) async {
    _selectedAnswerList = [];
    List<WordListDBInformation> wordPool = _wordListPool!;

    // Rastgele 5 cevap seçme işlemi
    wordPool.shuffle();
    for (int i = 0; i < min(5, wordPool.length); i++) {
      String answer = wordPool[i].word!;
      bool isCorrect = (answer == selectedWord?.word);
      _selectedAnswerList!.add(GameAnswerModel(answer, isCorrect));
    }
  }

  Future<void> checkAnswer(GameAnswerModel selectedAnswer) async {
    if (selectedAnswer.isCorrect) {
      // Diğer işlemler
      _successAccuried = true;
      notifyListeners();
      await Future.delayed(Duration(seconds: 2));
      await takeWord();
      _successAccuried = false;
      notifyListeners();
    } else {
      _errorAccuried = true;
      notifyListeners();

      Timer(Duration(seconds: 2), () async {
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
  }
}

class GameAnswerModel {
  String answer;
  bool isCorrect;

  GameAnswerModel(this.answer, this.isCorrect);
}
