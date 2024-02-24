// ignore_for_file: file_names, unnecessary_new, avoid_function_literals_in_foreach_calls, non_constant_identifier_names, avoid_unnecessary_containers

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patikmobile/models/dialog.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DialogCategoriesProvider extends ChangeNotifier {
  final dbProvider = DbProvider();
  final List<DialogListInformation> wordList = [];

  List<DialogListInformation> categoryList = [];
  List<DialogListDBInformation> dialogs = [];

  bool isLoadList = false;
  bool isDialogListLoaded = false;

  init(BuildContext context) async {
    getCategories(context);
  }

  void getCategories(BuildContext context) async {
    categoryList = await dbProvider.getDialogCategories(context);
    isLoadList = true;
    //_categoryList = await AppDbProvider().setCategoryAppLng(_categoryList);
    notifyListeners();
  }

  Widget CategoryItem(BuildContext context, Uint8List image) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SvgPicture.memory(
            image,
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Container(
            child: const Column(
              children: <Widget>[Expanded(child: Text("Test"))],
            ),
          ),
        ],
      ),
    );
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

  void dialogPageInit(String? dialogId, BuildContext context) async {
    String currentLanguage = await getCurrentLanguageAsString();

    Directory dir = await getApplicationDocumentsDirectory();
    dialogs = [];
    var dialogList =
        await dbProvider.getDialogListSelectedCategories(context, dialogId!);

    for (var x in dialogList) {
      final wordSound =
          '${dir.path}/$currentLanguage/${currentLanguage}_${x.dbId}.mp3';

      DialogListDBInformation wordInfo = DialogListDBInformation(
        audio: wordSound,
        word: x.categoryName,
        wordA: x.categoryAppLngName,
        wordT: "okunuşu",
        id: 0,
      );

      dialogs.add(wordInfo);
    }
    isDialogListLoaded = true;
    notifyListeners();
    print(dialogs);
  }
}
