// ignore_for_file: prefer_final_fields, avoid_print, use_build_context_synchronously, unused_local_variable, prefer_const_constructors
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/pages/box_page.dart';
import 'package:patikmobile/pages/games/match_with_picture_game.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:patikmobile/services/image_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:sqflite/sqflite.dart';

class SwipeCardGameProvider extends ChangeNotifier {
  final apirepository = APIRepository();
  final database = Database;

  bool? _wordsLoaded = false;
  bool? get wordsLoaded => _wordsLoaded;

  List<Word>? _selectedCategoryWords;
  List<Word>? get selectedCategoryWords => _selectedCategoryWords;

  List<WordListDBInformation>? _wordListDbInformation;
  List<WordListDBInformation>? get wordListDbInformation =>
      _wordListDbInformation;

  init(WordListInformation? selectedCategoryInfo,
      [BuildContext? context]) async {
    if (selectedCategoryInfo != null && selectedCategoryInfo.dbId != null) {
      await startSwipeCardGame(selectedCategoryInfo.dbId, context!);
      notifyListeners();
    }
    // getCountInformation();
  }

  void resetData() {
    _wordsLoaded = false;
    _wordListDbInformation = [];
    _selectedCategoryWords = [];
    notifyListeners();
  }

  Future<void> startSwipeCardGame(String? dbId, BuildContext context) async {
    //KAYIT EDİLEN 5 KELİMEYİ EN BAŞTA TEMİZLİYORUM. ÇÜNKÜ EĞER OYUNUN ORTASINDA ÇIKAR İSE EN BAŞTAN BAŞLAMALI.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('selectedWords', []);

    _wordsLoaded = false;
    DbProvider dbProvider = DbProvider();
    //ADIM 1 ==> Seçilen dbId si ile öncelikle o kategoriye ait liste getirilir.
    _selectedCategoryWords = await getCategoriesWordsFromDB(dbId, dbProvider);
    //ADIM 2 ==> Seçilen kelimelere ait Veritabanından resimleri ve sesleri getirilir.
    await getWordsFileInformationFromStorage(_selectedCategoryWords);
    if (_selectedCategoryWords != null && _selectedCategoryWords!.isNotEmpty) {
      _wordsLoaded = true;
      notifyListeners();
    }
    if (_selectedCategoryWords!.isEmpty) {
      Navigator.pop(context);

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              BoxPage(selectedBox: 0, completedGame: true, dbId: dbId)));
    } else {
      //ADIM 3 ==> Seçilen 5 kelimeyi kayıt altında tut! (Diğer oyunlar için kullanacağız)
      await saveSelectedWords(_selectedCategoryWords!);
      var words = await getSavedWords();
    }
    print(_selectedCategoryWords);
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

  Future<List<Word>> getCategoriesWordsFromDB(
      String? dbId, DbProvider dbProvider) async {
    _selectedCategoryWords = await dbProvider.getRandomWordList(
        dbId: dbId, withoutCategoryName: true);

    return _selectedCategoryWords!;
  }

  getWordsFileInformationFromStorage(List<Word>? selectedCategoryWords) async {
    _wordListDbInformation = [];
    String currentLanguage = await getCurrentLanguageAsString();

    Directory dir = await getApplicationDocumentsDirectory();

    if (selectedCategoryWords!.isNotEmpty) {
      for (var x in selectedCategoryWords) {
        final wordSound =
            '${dir.path}/$currentLanguage/${currentLanguage}_${x.id}.mp3';

        WordListDBInformation wordInfo = WordListDBInformation(
            audio: wordSound,
            image: getWordImage(x.id.toString(), x.imgLngPath, height: 7.w),
            imgLngPath: x.imgLngPath,
            word: x.word,
            wordA: x.wordA,
            wordT: x.wordT,
            id: x.id,
            wordAppLng: x.wordAppLng);

        _wordListDbInformation!.add(wordInfo);
      }
      // WordListDBInformation lastCard = WordListDBInformation(
      //   lastCard: true,
      //   word: "Tüm kartları öğrendiniz",
      // );
      // _wordListDbInformation!.add(lastCard);
    }
    print(_wordListDbInformation);
  }

  Future<String> getCurrentLanguageAsString() async {
    if (StorageProvider.learnLanguge != null) {
      return StorageProvider.learnLanguge!.Code;
    }

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

    Timer(Duration(milliseconds: 100), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MatchWithPictureGame()),
          (Route<dynamic> route) => false);
    });
  }
}
