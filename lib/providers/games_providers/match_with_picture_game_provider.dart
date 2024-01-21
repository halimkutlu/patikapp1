// ignore_for_file: prefer_final_fields, avoid_print, use_build_context_synchronously, unused_local_variable, prefer_const_constructors
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/pages/games/match_with_picture_game.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class MatchWithPictureGameProvide extends ChangeNotifier {
  final apirepository = APIRepository();
  final database = Database;

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
    await startMatchWithImageGame();
    // if (selectedCategoryInfo != null && selectedCategoryInfo.dbId != null) {
    //   await startSwipeCardGame(selectedCategoryInfo.dbId, context!);
    //   notifyListeners();
    // }
    // getCountInformation();
  }

  Future<void> startMatchWithImageGame() async {
    //1. ADIM ==> Öncelikle bir önceki aşamada seçilen 5 kart local storage üzerinden getirilir.
    List<Word> words = await getSavedWords();
    //2. ADIM ==> Seçilen kartların db verileri çekilir.
    await getWordsFileInformationFromStorage(words);
    // _selectedWordInfo = _wordListDbInformation![0]; // İlk öğeyi seçelim.
    _wordsLoaded = true;
    notifyListeners();
  }

  // Future<void> startSwipeCardGame(String? dbId, BuildContext context) async {
  //   //KAYIT EDİLEN 5 KELİMEYİ EN BAŞTA TEMİZLİYORUM. ÇÜNKÜ EĞER OYUNUN ORTASINDA ÇIKAR İSE EN BAŞTAN BAŞLAMALI.
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setStringList('selectedWords', []);

  //   _wordsLoaded = false;
  //   DbProvider dbProvider = DbProvider();
  //   //ADIM 1 ==> Seçilen dbId si ile öncelikle o kategoriye ait liste getirilir.
  //   // _selectedCategoryWords = await getCategoriesWordsFromDB(dbId, dbProvider);
  //   //ADIM 2 ==> Seçilen kelimelere ait Veritabanından resimleri ve sesleri getirilir.
  //   await getWordsFileInformationFromStorage(_selectedCategoryWords);
  //   if (_selectedCategoryWords != null && _selectedCategoryWords!.isNotEmpty) {
  //     _wordsLoaded = true;
  //     notifyListeners();
  //   }
  //   if (_selectedCategoryWords!.isEmpty) {
  //     CustomAlertDialogOnlyConfirm(context, () {
  //       Navigator.pop(context);
  //       Navigator.pop(context);
  //     }, "warning".tr, "Kategoriye ait kelime bulunamadı",
  //         ArtSweetAlertType.info, "ok".tr);
  //   } else {
  //     //ADIM 3 ==> Seçilen 5 kelimeyi kayıt altında tut! (Diğer oyunlar için kullanacağız)
  //     await saveSelectedWords(_selectedCategoryWords!);
  //     var words = await getSavedWords();
  //   }
  //   print(_selectedCategoryWords);
  // }

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
            File('${dir.path}/$currentLanguage/${currentLanguage}_${x.id}.mp3');

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

  void selectWord(WordListDBInformation selectedInfo) {
    if (_selectedImage != null && (selectedInfo.isWordCorrect != true)) {
      _selectedWordInfo = selectedInfo;
      print(_selectedWordInfo);
      selectedInfo.isWordSelected = true;
      notifyListeners();

      checkMatch();
    }
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

  void resetSelections() {
    _errorCount = _errorCount! + 1;
    _selectedImage!.isImageCorrect = null;
    _selectedWordInfo!.isWordCorrect = null;

    _selectedWordInfo!.isImageSelected = false;
    _selectedWordInfo!.isWordSelected = null;

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
      //REKLAM GÖSTER
    }
  }
}
