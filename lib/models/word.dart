// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:patikmobile/api/static_variables.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/providers/storageProvider.dart';

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

Map<String, String> categoryImageMap = {
  "-1": "1",
  "-2": "12",
  "-3": "64",
  "-4": "78",
  "-5": "98",
  "-6": "119",
  "-7": "133",
  "-8": "158",
  "-9": "185",
  "-10": "218",
  "-11": "253",
  "-12": "299",
  "-13": "335",
  "-14": "365",
  "-15": "423",
  "-16": "463",
  "-17": "506",
  "-18": "553",
  "-19": "563",
  "-20": "688",
  "-21": "718",
  "-22": "740",
  "-23": "762",
  "-24": "809",
  "-25": "827",
  "-26": "850",
  "-27": "950"
};

File getCategoryImage(String path, String categoryId) => File(
    '$path/${StorageProvider.learnLanguge!.Code}/${StorageProvider.learnLanguge!.Code}_${categoryImageMap[categoryId]}.svg');

class WordListInformation {
  String? categoryName;
  int? categoryWordCount;
  int? totalCount;
  File? categoryImage;
  String? categoryOrderName;
  int? order;
  int? orderColor;
  String? dbId;
  String? categoryAppLngName;

  WordListInformation({
    this.categoryImage,
    this.categoryName,
    this.categoryWordCount,
    this.order,
    this.categoryOrderName,
    this.orderColor,
    this.totalCount,
    this.dbId,
    this.categoryAppLngName = "",
  });

  factory WordListInformation.fromMap(String path, Map<String, dynamic> json,
          BuildContext context, bool isCategory) =>
      WordListInformation(
          dbId: json["Id"].toString(),
          categoryName: json["Word"],
          categoryWordCount: json["CategoryWordCount"],
          categoryOrderName: WordListInformation.getCategoryOrderName(
              context, json["Activities"]),
          orderColor: StaticVariables
              .ColorList[(int.tryParse(json["Activities"]) ?? 0) - 1],
          totalCount: json["TotalWordCount"],
          order: json["IsCategory"] != 1
              ? int.tryParse(json["Activities"]) ?? json["OrderId"]
              : null,
          categoryAppLngName: "",
          categoryImage: !isCategory
              ? null
              : getCategoryImage(path, json["Id"].toString()));

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
