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

List<CategoryItem> CategoryItemList = [
  CategoryItem("107", "112", "28", 1),
  CategoryItem("107", "110", "49", 1),
  CategoryItem("107", "113", "63", 1),
  // CategoryItem("107", "", ""),
  // CategoryItem("107", "", ""),
  // CategoryItem("107", "", ""),
  // CategoryItem("107", "", ""),
  CategoryItem("115", "116", "1", 2),
  CategoryItem("115", "117", "77", 2),
  CategoryItem("115", "119", "110", 2),
  CategoryItem("115", "58", "156", 2),
  CategoryItem("115", "120", "192", 2),
  CategoryItem("115", "118", "222", 2),
  CategoryItem("115", "121", "257", 2),
  // CategoryItem("", "", ""),
  // CategoryItem("", "", ""),
  // CategoryItem("", "", ""),
  // CategoryItem("", "", ""),
  // CategoryItem("", "", ""),
  // CategoryItem("", "", ""),
  // CategoryItem("", "", ""),
  CategoryItem("115", "116", "1", 3),
  CategoryItem("115", "117", "77", 3),
  CategoryItem("115", "119", "110", 3),
  CategoryItem("115", "58", "156", 3),
  CategoryItem("115", "120", "192", 3),
  CategoryItem("115", "118", "222", 3),
  CategoryItem("115", "121", "257", 3),
  // CategoryItem("", "", ""),
  // CategoryItem("", "", ""),
  // CategoryItem("", "", ""),
  // CategoryItem("", "", ""),
  // CategoryItem("", "", ""),
  // CategoryItem("", "", ""),
  // CategoryItem("", "", ""),
  // CategoryItem("", "", ""),
  // CategoryItem("", "", ""),
  // CategoryItem("", "", ""),
  CategoryItem("115", "116", "1", 4),
  CategoryItem("115", "117", "77", 4),
  CategoryItem("115", "119", "110", 4),
  CategoryItem("115", "58", "156", 4),
  CategoryItem("115", "120", "192", 4),
  CategoryItem("115", "118", "222", 4),
  CategoryItem("115", "121", "257", 4),
  // CategoryItem("", "", ""),
  // CategoryItem("", "", ""),
  // CategoryItem("", "", ""),
];

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

  List<int> ColorList = [
    0xFF1A57FF,
    0xFF22AA00,
    0xFFC70000,
    0xFFFF761A,
  ];

  void getCategories(BuildContext context) async {
    _categoryList = [];
    List<Word> list = await dbProvider.getWordList(withoutCategoryName: true);
    for (CategoryItem item in CategoryItemList) {
      _categoryList.add(WordListInformation(
        categoryName: item.getName(context),
        categoryImage: "",
        totalCount: list.length,
        order: item.StepOrder,
        orderColor: ColorList[item.StepOrder - 1],
        categoryOrderName: item.getStepName(context),
        dbId: item.DbId,
        categoryWordCount: list
            .where(
                (element) => element.categories!.split(',').contains(item.DbId))
            .length,
      ));
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
    notifyListeners();

    print(list);
    print('Learned Count: $_getLernedWordCount');
    print('Repeat Count: $_getRepeatedWordCount');
    print('Work Hard Count: $_getWorkHardCount');
  }
}
