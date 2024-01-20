// ignore_for_file: prefer_final_fields, avoid_print, use_build_context_synchronously
import 'dart:io';

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

class SwipeCardGameProvider extends ChangeNotifier {
  final apirepository = APIRepository();

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
    }
    print(_selectedCategoryWords);
  }

  Future<List<Word>> getCategoriesWordsFromDB(
      String? dbId, DbProvider dbProvider) async {
    List<Word> allWords =
        await dbProvider.getWordList(withoutCategoryName: true);
    if (allWords.isNotEmpty) {
      _selectedCategoryWords =
          allWords.where((x) => x.categories == dbId).toList();
    }
    return _selectedCategoryWords!;
  }

  getWordsFileInformationFromStorage(List<Word>? selectedCategoryWords) async {
    _wordListDbInformation = [];
    String currentLanguage = await getCurrentLanguageAsString();

    Directory dir = await getApplicationDocumentsDirectory();

    if (selectedCategoryWords!.isNotEmpty) {
      selectedCategoryWords.forEach((x) {
        final wordImage =
            File('${dir.path}/$currentLanguage/${currentLanguage}_${x.id}.svg');
        final wordSound =
            File('${dir.path}/$currentLanguage/${currentLanguage}_${x.id}.mp3');

        WordListDBInformation wordInfo = WordListDBInformation(
          audio: wordSound,
          imageUrl: wordImage,
          word: x.word,
          wordA: x.wordA,
          wordT: x.wordT,
        );

        _wordListDbInformation!.add(wordInfo);
      });
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
