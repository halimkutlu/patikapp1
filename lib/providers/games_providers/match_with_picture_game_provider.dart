// ignore_for_file: prefer_final_fields, avoid_print, use_build_context_synchronously, unused_local_variable, prefer_const_constructors
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/pages/games/match_with_picture_game.dart';
import 'package:patikmobile/pages/games/math_with_sound_game.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:patikmobile/services/ad_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class MatchWithPictureGameProvide extends ChangeNotifier {
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

  WordListDBInformation? _selectedImage;
  WordListDBInformation? get selectedImage => _selectedImage;

  bool? _errorAccuried = false;
  bool? get errorAccuried => _errorAccuried;

  int? _errorCount = 0;
  int? get errorCount => _errorCount;

  init([BuildContext? context]) async {
    _isShuffled = false;
    _errorCount = 0;
    loadAd();
    await startMatchWithImageGame();
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

  Future<void> startMatchWithImageGame() async {
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
    _selectedImage = null;
    _selectedWordInfo = null;
  }

  getWordsFileInformationFromStorage(List<Word>? selectedCategoryWords) async {
    _wordListDbInformation = [];
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
            id: x.id);

        _wordListDbInformation!.add(wordInfo);
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

  void selectImage(WordListDBInformation selectedInfo) {
    _selectedImage = selectedInfo;
    print(_selectedImage);
    selectedInfo.isImageSelected = true;
    notifyListeners();
  }

  void resetSelectImage(WordListDBInformation info) {
    resetSelections();
  }

  void selectWord(WordListDBInformation selectedInfo, BuildContext context) {
    if (_selectedImage != null && (selectedInfo.isWordCorrect != true)) {
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
          MaterialPageRoute(builder: (context) => MatchWithSoundGame()),
          (Route<dynamic> route) => false);
    });
  }

  bool checkMatch() {
    if (_selectedImage != null && _selectedWordInfo != null) {
      if (_selectedImage!.word == _selectedWordInfo!.word) {
        _selectedWordInfo!.isWordCorrect = true;
        _selectedImage!.isImageCorrect = true;

        _selectedWordInfo!.isImageSelected = false;
        _selectedWordInfo!.isWordSelected = false;

        //seçimler temizlenir
        _selectedImage = null;
        _selectedWordInfo = null;
        //----
        notifyListeners();

        return true;
      } else {
        _selectedImage!.isImageCorrect = false;
        _selectedWordInfo!.isWordCorrect = false;

        _selectedWordInfo!.isImageSelected = false;
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
        .firstWhere((element) => element.id == _selectedImage!.id);
    word.errorCount = word.errorCount! + 1;

    _errorCount = _errorCount! + 1;
    _selectedImage!.isImageCorrect = null;

    if (_selectedWordInfo != null) {
      _selectedWordInfo!.isWordCorrect = null;

      _selectedWordInfo!.isImageSelected = false;
      _selectedWordInfo!.isWordSelected = null;
    }

    _wordListDbInformation?.forEach(
      (element) {
        element.isWordSelected = false;
        element.isImageSelected = false;
      },
    );

    //seçimler temizlenir
    _selectedImage = null;
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
