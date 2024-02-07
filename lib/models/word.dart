// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:patikmobile/api/static_variables.dart';
import 'package:patikmobile/locale/app_localizations.dart';

class Word {
  int? id;
  String? word;
  String? wordA;
  String? wordT;
  bool? isCategoryName;
  String? categories;
  String? activities;
  int? orderId;
  String? wordAppLng;

  int? errorCount = 0;

  Word(
      {this.id,
      this.word,
      this.wordA,
      this.wordT,
      this.isCategoryName,
      this.categories,
      this.activities,
      this.orderId,
      this.errorCount = 0,
      this.wordAppLng = ""});

  factory Word.fromMap(Map<String, dynamic> json) => Word(
      id: json["Id"],
      word: json["Word"],
      wordA: json["WordA"],
      wordT: json["WordT"],
      isCategoryName: json["IsCategoryName"] == 1,
      categories: json["Categories"],
      activities: json["Activities"],
      orderId: json["OrderId"],
      errorCount: json["errorCount"] ?? 0,
      wordAppLng: json["wordAppLng"]);

  Map<String, dynamic> toMap() => {
        "Id": id,
        "Word": word,
        "WordA": wordA,
        "WordT": wordT,
        "IsCategoryName": isCategoryName! ? 1 : 0,
        "Categories": categories,
        "Activities": activities,
        "OrderId": orderId,
        "errorCount": errorCount ?? 0,
        "wordAppLng": wordAppLng
      };

  String toJson() {
    final Map<String, dynamic> data = toMap();
    return json.encode(data);
  }

  factory Word.fromJson(String str) {
    final Map<String, dynamic> data = json.decode(str);
    return Word.fromMap(data);
  }
}

class WordListInformation {
  String? categoryName;
  int? categoryWordCount;
  int? totalCount;
  String? categoryImage;
  String? categoryOrderName;
  int? order;
  int? orderColor;
  String? dbId;
  String? categoryAppLngName;

  WordListInformation(
      {this.categoryImage,
      this.categoryName,
      this.categoryWordCount,
      this.order,
      this.categoryOrderName,
      this.orderColor,
      this.totalCount,
      this.dbId,
      this.categoryAppLngName = ""});

  factory WordListInformation.fromMap(
          Map<String, dynamic> json, BuildContext context) =>
      WordListInformation(
          dbId: json["Id"].toString(),
          categoryName: json["Word"],
          categoryImage: "",
          categoryWordCount: json["CategoryWordCount"],
          categoryOrderName: WordListInformation.getCategoryOrderName(
              context, json["Activities"]),
          orderColor: StaticVariables
              .ColorList[(int.tryParse(json["Activities"]) ?? 0) - 1],
          totalCount: json["TotalWordCount"],
          order: json["IsCategory"] != 1
              ? int.tryParse(json["Activities"]) ?? json["OrderId"]
              : null,
          categoryAppLngName: "");

  static getCategoryOrderName(BuildContext context, String activities) {
    var key = "107";
    if (activities == "2")
      key = "115";
    else if (activities == "3")
      key = "123";
    else if (activities == "4") key = "133";

    return AppLocalizations.of(context).translate(key);
  }
}

class WordListDBInformation {
  String? word;
  String? wordA;
  String? wordT;
  String? audio;
  Uint8List? imageBytes;
  int? id;
  String? wordAppLng;
  bool? isAddedToWorkHard = false;
  bool? lastCard = false;

  //kelime eşleştirme modeli
  bool? isWordCorrect;
  bool? isWordSelected;
  //resim
  bool? isImageCorrect;
  bool? isImageSelected;
  //ses
  bool? isSoundCorrect;
  bool? isSoundListened;

  WordListDBInformation(
      {this.audio,
      this.imageBytes,
      this.word,
      this.wordA,
      this.wordT,
      this.id,
      this.isAddedToWorkHard,
      this.lastCard = false,
      this.wordAppLng = ""});

  WordListDBInformation.fromMap(Word w)
      : word = w.word,
        wordA = w.wordA,
        wordT = w.wordT;
}
