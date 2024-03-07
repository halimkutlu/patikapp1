// ignore_for_file: prefer_final_fields, avoid_print
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/models/word_statistics.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class BoxPageProvider extends ChangeNotifier {
  final apirepository = APIRepository();
  final database = Database;

  bool? _wordsLoaded = false;
  bool? get wordsLoaded => _wordsLoaded;

  List<WordListDBInformation>? _wordListDbInformation;
  List<WordListDBInformation>? get wordListDbInformation =>
      _wordListDbInformation;

  List<Word>? _selectedCategoryWords;
  List<Word>? get selectedCategoryWords => _selectedCategoryWords;

  int? _getLernedWordCount = 0;
  int get getLernedWordCount => _getLernedWordCount!;

  int? _getRepeatedWordCount = 0;
  int get getRepeatedWordCount => _getRepeatedWordCount!;

  int? _getWorkHardCount = 0;
  int get getWorkHardCount => _getWorkHardCount!;

  int? _roleid = 0;
  int get roleid => _roleid!;
  init(BuildContext context, int selectedBox, bool? completedGame,
      String? dbId) async {
    _selectedCategoryWords = [];
    await getCountInformation();
    await getListOfWords(selectedBox, completedGame, dbId);
    await getWordsFileInformationFromStorage(_selectedCategoryWords);
    if (_selectedCategoryWords != null && _selectedCategoryWords!.isNotEmpty) {
      _wordsLoaded = true;
    }
    notifyListeners();
  }

  Future<void> getCountInformation() async {
    DbProvider dbProvider = DbProvider();

    List<WordStatistics> list = await dbProvider.getWordStatisticsList();
    _getLernedWordCount =
        list.where((wordStat) => wordStat.learned == 1).length;
    _getRepeatedWordCount =
        list.where((wordStat) => wordStat.repeat == 1).length;
    _getWorkHardCount = list.where((wordStat) => wordStat.workHard == 1).length;

    print(list);
    print('Learned Count: $_getLernedWordCount');
    print('Repeat Count: $_getRepeatedWordCount');
    print('Work Hard Count: $_getWorkHardCount');
    notifyListeners();
  }

  getListOfWords(int selectedBox, bool? completedGame, String? dbId) async {
    DbProvider dbProvider = DbProvider();
    await getCategoriesWordsFromDB(
        dbProvider, selectedBox, completedGame, dbId);
  }

  Future<List<Word>> getCategoriesWordsFromDB(DbProvider dbProvider,
      int selectedBox, bool? completedGame, String? dbId) async {
    List<Word> allWords = [];
    if (selectedBox == 0 && completedGame!) {
      allWords = await dbProvider.getWordListById(dbId);
      _selectedCategoryWords = allWords.toList();

      return _selectedCategoryWords!;
    } else {
      allWords = await dbProvider.getWordList(withoutCategoryName: true);

      List<WordStatistics> allWordStatistics =
          await dbProvider.getWordStatisticsList();

      if (allWords.isNotEmpty) {
        //seçilen kutuya göre filtrelenir
        allWordStatistics = allWordStatistics
            .where((element) => selectedBox == 1
                ? element.learned == 1
                : selectedBox == 2
                    ? element.repeat == 1
                    : element.workHard == 1)
            .toList();

        // allWordStatistics içindeki WordId'leri al
        Set<int> existingWordIds =
            allWordStatistics.map((statistics) => statistics.wordId!).toSet();

        // allWords içinde allWordStatistics'te bulunmayan WordId'lere sahip kelimeleri filtrele
        _selectedCategoryWords = allWords
            .where(
              (word) => existingWordIds.contains(word.id),
            )
            .toList();
      }

      return _selectedCategoryWords!;
    }
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
}
