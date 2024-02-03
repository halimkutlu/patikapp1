// ignore_for_file: prefer_final_fields, avoid_print, use_build_context_synchronously, unused_local_variable, prefer_const_constructors
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/pages/games/fill_the_blank_game.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:patikmobile/services/ad_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class MatchWithSoundGameProvide extends ChangeNotifier {
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

  init([BuildContext? context]) async {
    _isShuffled = false;
    _errorCount = 0;
    loadAd();
    await startMatchWithSoundGame();
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

  Future<void> startMatchWithSoundGame() async {
    //1. ADIM ==> Öncelikle bir önceki aşamada seçilen 5 kart local storage üzerinden getirilir.
    comingWordListFromStorage = await getSavedWords();
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
  }

  getWordsFileInformationFromStorage(List<Word>? selectedCategoryWords) async {
    _wordListDbInformation = [];
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
      }
    }
    print(_wordListDbInformation);
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
    resetData();

    Timer(Duration(milliseconds: 100), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => FillTheBlankGame()),
          (Route<dynamic> route) => false);
    });
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

        Timer(Duration(seconds: 2), () {
          resetSelections();
        });
        return false;
      }
    }
    return false;
  }

  void resetSelections() async {
    var word = comingWordListFromStorage
        .firstWhere((element) => element.id == _listenedSound!.id);
    word.errorCount = word.errorCount! + 1;

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
}