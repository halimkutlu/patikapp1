// ignore_for_file: prefer_final_fields, avoid_print, use_build_context_synchronously, unused_local_variable
import 'dart:io';
import 'dart:math';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/models/word_statistics.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      CustomAlertDialogOnlyConfirm(context, () {
        Navigator.pop(context);
        Navigator.pop(context);
      }, "warning".tr, "Kategoriye ait kelime bulunamadı",
          ArtSweetAlertType.info, "ok".tr);
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
    List<Word> allWords =
        await dbProvider.getWordList(withoutCategoryName: true);

    List<WordStatistics> allWordStatistics =
        await dbProvider.getWordStatisticsList();

    if (allWords.isNotEmpty) {
      // Rastgele sıralama işlemi
      Random random = Random();
      allWords.shuffle(random);

      // allWordStatistics içindeki WordId'leri al
      Set<int> existingWordIds =
          allWordStatistics.map((statistics) => statistics.wordId!).toSet();

      // allWords içinde allWordStatistics'te bulunmayan WordId'lere sahip kelimeleri filtrele
      _selectedCategoryWords = allWords
          .where(
            (word) =>
                word.categories == dbId && !existingWordIds.contains(word.id),
          )
          .take(5)
          .toList();
    }

    return _selectedCategoryWords!;
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
            imageUrl: wordImage,
            word: x.word,
            wordA: x.wordA,
            wordT: x.wordT,
            id: x.id);

        _wordListDbInformation!.add(wordInfo);
      }
      WordListDBInformation lastCard = WordListDBInformation(
        lastCard: true,
        word: "Tüm kartları öğrendiniz",
      );
      _wordListDbInformation!.add(lastCard);
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
}
