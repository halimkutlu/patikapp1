// ignore_for_file: prefer_final_fields, avoid_print, use_build_context_synchronously, unused_local_variable, prefer_const_constructors
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/pages/games/math_with_sound_game.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:patikmobile/services/ad_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class FillTheBlankGameProvider extends ChangeNotifier {
  final apirepository = APIRepository();
  final database = Database;

  InterstitialAd? _interstitialAd;
  InterstitialAd get interstitialAd => _interstitialAd!;

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

  int? _errorCount = 0;
  int? get errorCount => _errorCount;

  init([BuildContext? context]) async {
    _selectedWord = null;
    _selectedWordTextEditingController = TextEditingController();
    _errorCount = 0;
    _wordsLoaded = false;
    loadAd();
    await startFillTheBlankGame();
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

  Future<void> startFillTheBlankGame() async {
    //1. ADIM ==> Öncelikle bir önceki aşamada seçilen 5 kart local storage üzerinden getirilir.
    comingWordListFromStorage = await getSavedWords();
    //2. ADIM ==> Seçilen kartların db verileri çekilir.
    await getWordsFileInformationFromStorage(comingWordListFromStorage);
    // _selectedWordInfo = _wordListDbInformation![0]; // İlk öğeyi seçelim.

    await takeWord();
    notifyListeners();
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
    } else {
      //oyun bitmiştir

      print("TEBRİKLER");
    }
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
    // _wordsLoaded = false;
    // _wordListDbInformation = [];
    // _listenedSound = null;
    // _selectedWordInfo = null;
  }

  getWordsFileInformationFromStorage(List<Word>? selectedCategoryWords) async {
    _wordListDbInformation = [];
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
      }
    }
    print(_wordListDbInformation);
  }

  void goToNextGame(BuildContext context) {
    resetData();

    Timer(Duration(milliseconds: 100), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MatchWithSoundGame()),
          (Route<dynamic> route) => false);
    });
  }

  void resetSelections() async {
    // var word = comingWordListFromStorage
    //     .firstWhere((element) => element.id == _listenedSound!.id);
    // word.errorCount = word.errorCount! + 1;

    // _errorCount = _errorCount! + 1;
    // _listenedSound!.isSoundCorrect = null;

    // if (_selectedWordInfo != null) {
    //   _selectedWordInfo!.isWordCorrect = null;

    //   _selectedWordInfo!.isSoundListened = false;
    //   _selectedWordInfo!.isWordSelected = null;
    // }

    // _wordListDbInformation?.forEach(
    //   (element) {
    //     element.isWordSelected = false;
    //     element.isSoundListened = false;
    //   },
    // );

    // //seçimler temizlenir
    // _listenedSound = null;
    // _selectedWordInfo = null;
    // _errorAccuried = false;
    // //----
    // notifyListeners();

    // if (_errorCount! > 3) {
    //   if (_interstitialAd != null) {
    //     await loadAd();
    //     _errorCount = 0;
    //     _interstitialAd?.show();

    //     //REKLAM GÖSTER6
    //   }
    // }
  }

  Future<void> wrongCharacter() async {
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
