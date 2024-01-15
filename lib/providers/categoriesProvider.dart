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

  int? _getLernedWordCount = 0;
  int get getLernedWordCount => _getLernedWordCount!;

  int? _getRepeatedWordCount = 0;
  int get getRepeatedWordCount => _getRepeatedWordCount!;

  int? _getWorkHardCount = 0;
  int get getWorkHardCount => _getWorkHardCount!;

  int? _roleid = 0;
  int get roleid => _roleid!;
  init() async {
    getCategories();
    // getCountInformation();
  }

  void getCategories() async {
    List<WordListInformation> wordList;

    List<Word> list = await dbProvider.getWordList();
    List<Word> categories =
        list.where((x) => x.isCategoryName == true).toList();
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
