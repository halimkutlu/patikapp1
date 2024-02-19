// ignore_for_file: file_names, unnecessary_new, avoid_function_literals_in_foreach_calls, non_constant_identifier_names, avoid_unnecessary_containers

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:patikmobile/models/dialog.dart';
import 'package:patikmobile/providers/dbprovider.dart';

class DialogCategoriesProvider extends ChangeNotifier {
  final dbProvider = DbProvider();
  final List<DialogListInformation> wordList = [];

  List<DialogListInformation> categoryList = [];
  bool isLoadList = false;

  init(BuildContext context) async {
    getCategories(context);
  }

  void getCategories(BuildContext context) async {
    categoryList = await dbProvider.getDialogCategories(context);
    for (var element in categoryList) {
      element.categoryIcon =
          await File(element.categoryIconPath!).readAsBytes();
      element.categoryBackgroundImage =
          await File(element.categoryBackgroundImagePath!).readAsBytes();
    }
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
}
