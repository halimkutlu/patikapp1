// ignore_for_file: prefer_final_fields, avoid_print, unused_local_variable, non_constant_identifier_names, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/models/word_statistics.dart';
import 'package:patikmobile/providers/dbprovider.dart';

class CategoryItem {
  final int StepOrder;
  final String DbId;
  final String StepId;
  final String AppLngId;
  CategoryItem(this.StepId, this.AppLngId, this.DbId, this.StepOrder);

  getName(BuildContext context) =>
      AppLocalizations.of(context).translate(AppLngId);

  getStepName(BuildContext context) =>
      AppLocalizations.of(context).translate(StepId);
}

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
  init(BuildContext context) async {
    getCategories(context);
    getCountInformation();
  }

  void getCategories(BuildContext context) async {
    _categoryList = await dbProvider.getCategories(context);
    //_categoryList = await AppDbProvider().setCategoryAppLng(_categoryList);
    notifyListeners();
  }

  void getCountInformation() async {
    List<WordStatistics> list = await dbProvider.getWordStatisticsList();
    _getLernedWordCount =
        list.where((wordStat) => wordStat.learned == 1).length;
    _getRepeatedWordCount =
        list.where((wordStat) => wordStat.repeat == 1).length;
    _getWorkHardCount = list.where((wordStat) => wordStat.workHard == 1).length;
    notifyListeners();

    print(list);
    print('Learned Count: $_getLernedWordCount');
    print('Repeat Count: $_getRepeatedWordCount');
    print('Work Hard Count: $_getWorkHardCount');
  }
}
