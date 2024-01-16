// ignore_for_file: prefer_final_fields, avoid_print, unused_local_variable
import 'package:flutter/material.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/models/word_statistics.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:patikmobile/providers/dashboardProvider.dart';

class CategoriesProvider extends ChangeNotifier {
  final apirepository = APIRepository();
  final dbProvider = DbProvider();
  final List<WordListInformation> wordList = [];

  int? _getLernedWordCount = 0;
  int get getLernedWordCount => _getLernedWordCount!;

  int? _getRepeatedWordCount = 0;
  int get getRepeatedWordCount => _getRepeatedWordCount!;

  int? _getWorkHardCount = 0;
  int get getWorkHardCount => _getWorkHardCount!;

  List<WordListInformation> _categoryList = [];
  List<WordListInformation> get categoryList => _categoryList;

  int? _roleid = 0;
  int get roleid => _roleid!;
  init() async {
    getCategories();
    getCountInformation();
  }

  List<String> CategoryNames = [
    "Birinci Adım",
    "İkinci Adım",
    "Üçüncü Adım",
    "Dördüncü Adım",
    "Adım dışı"
  ];
  List<int> ColorList = [
    0xFF1A57FF,
    0xFF22AA00,
    0xFFC70000,
    0xFFFF761A,
  ];

  void getCategories() async {
    _categoryList = [];
    List<Word> list = await dbProvider.getWordList();
    List<Word> categories =
        list.where((x) => x.isCategoryName == true).toList();

    int i = 1;
    int j = 1;
    for (var category in categories) {
      i++;
      var wordModel = WordListInformation(
          categoryName: category.word,
          categoryImage: "",
          totalCount: list.length,
          order: i % 4 == 0 ? ++j : j,
          orderColor: ColorList[j - 1],
          categoryOrderName: CategoryNames[j - 1],
          categoryWordCount: category.categories != null
              ? list
                  .where((x) =>
                      x.isCategoryName == false &&
                      (x.categories != null &&
                          x.categories! == category.id.toString()))
                  .length
              : 0);

      _categoryList.add(wordModel);
    }

    notifyListeners();
  }

  void getCountInformation() async {
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
  }
}
