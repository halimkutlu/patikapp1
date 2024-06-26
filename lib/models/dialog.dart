// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class Dialog {
  int? id;
  String? word;
  String? wordA;
  String? wordT;
  bool? isCategoryName;
  String? categories;
  String? activities;
  int? orderId;
  String? dialogAppLng;
  int? isFree;
  int? imgLngPath;

  int? errorCount = 0;

  Dialog(
      {this.id,
      this.word,
      this.wordA,
      this.wordT,
      this.isCategoryName,
      this.categories,
      this.activities,
      this.orderId,
      this.isFree,
      this.imgLngPath,
      this.errorCount = 0,
      this.dialogAppLng = ""});

  factory Dialog.fromMap(Map<String, dynamic> json) => Dialog(
      id: json["Id"],
      word: json["Word"],
      wordA: json["WordA"],
      wordT: json["WordT"],
      isCategoryName: json["IsCategoryName"] == 1,
      categories: json["Categories"],
      activities: json["Activities"],
      orderId: json["OrderId"],
      isFree: json["IsFree"],
      imgLngPath: json["ImgLngPath"],
      errorCount: json["errorCount"] ?? 0,
      dialogAppLng: json["dialogAppLng"]);

  Map<String, dynamic> toMap() => {
        "Id": id,
        "Word": word,
        "WordA": wordA,
        "WordT": wordT,
        "IsCategoryName": isCategoryName! ? 1 : 0,
        "Categories": categories,
        "Activities": activities,
        "OrderId": orderId,
        "IsFree": isFree,
        "ImgLngPath": imgLngPath,
        "errorCount": errorCount ?? 0,
        "dialogAppLng": dialogAppLng
      };

  String toJson() {
    final Map<String, dynamic> data = toMap();
    return json.encode(data);
  }

  factory Dialog.fromJson(String str) {
    final Map<String, dynamic> data = json.decode(str);
    return Dialog.fromMap(data);
  }
}

class DialogListInformation {
  String? categoryName;
  int? categoryDialogCount;
  int? totalCount;
  //Widget? categoryIcon;
  //Widget? categoryBackgroundImage;
  int? order;
  int? imgLngPath;
  int? orderColor;
  String? dbId;
  String? categoryAppLngName;

  DialogListInformation(
      { //this.categoryIcon,
      //this.categoryBackgroundImage,
      this.categoryName,
      this.categoryDialogCount,
      this.order,
      this.imgLngPath,
      this.totalCount,
      this.dbId,
      this.categoryAppLngName = ""});

  factory DialogListInformation.fromMap(
          Map<String, dynamic> json, BuildContext context) =>
      DialogListInformation(
          dbId: json["Id"].toString(),
          categoryName: json["Word"],
          //categoryIcon: getDialogImage(json["Id"], false),
          //categoryIcon: File('$dir/${StorageProvider.learnLanguge!.Code}/di${json["Id"]}.svg'),
          //categoryBackgroundImage: 'assets/dialogBackgroundImages/di${json["Id"]}.png',
          //categoryBackgroundImage: File('$dir/${StorageProvider.learnLanguge!.Code}/di${json["Id"]}.png'),
          categoryDialogCount: json["CategoryDialogCount"],
          totalCount: json["TotalDialogCount"],
          order: json["OrderId"],
          imgLngPath: json["ImgLngPath"],
          categoryAppLngName: "");
}

class DialogListDBInformation {
  String? word;
  String? wordA;
  String? wordT;
  String? audio;
  Uint8List? imageBytes;
  int? id;
  String? dialogAppLng;
  bool? isAddedToWorkHard = false;
  bool? lastCard = false;
  int? imgLngPath;

  //kelime eşleştirme modeli
  bool? isWordCorrect;
  bool? isWordSelected;
  //resim
  bool? isImageCorrect;
  bool? isImageSelected;
  //ses
  bool? isSoundCorrect;
  bool? isSoundListened;

  DialogListDBInformation(
      {this.audio,
      this.imageBytes,
      this.word,
      this.wordA,
      this.wordT,
      this.id,
      this.imgLngPath,
      this.isAddedToWorkHard,
      this.lastCard = false,
      this.dialogAppLng = ""});

  factory DialogListDBInformation.fromMap(
          Map<String, dynamic> json, String path, String currentLanguage) =>
      DialogListDBInformation(
          id: json["Id"],
          word: json["Word"],
          wordA: json["WordA"],
          wordT: json["WordT"],
          imgLngPath: json["ImgLngPath"],
          audio:
              '$path/$currentLanguage/${currentLanguage}_Di_${json["Id"]}.mp3');
}
