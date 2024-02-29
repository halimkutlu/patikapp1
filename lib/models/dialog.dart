// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

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
  String? categoryIconPath;
  File? categoryIcon;
  String? categoryBackgroundImagePath;
  File? categoryBackgroundImage;
  int? order;
  int? orderColor;
  String? dbId;
  String? categoryAppLngName;

  DialogListInformation(
      {this.categoryIconPath,
      this.categoryIcon,
      this.categoryBackgroundImagePath,
      this.categoryBackgroundImage,
      this.categoryName,
      this.categoryDialogCount,
      this.order,
      this.totalCount,
      this.dbId,
      this.categoryAppLngName = ""});

  factory DialogListInformation.fromMap(
          String dir, Map<String, dynamic> json, BuildContext context) =>
      DialogListInformation(
          dbId: json["Id"].toString(),
          categoryName: json["Word"],
          categoryIconPath:
              '$dir/${StorageProvider.learnLanguge!.Code}/di${json["Id"]}.svg',
          categoryIcon: File(
              '$dir/${StorageProvider.learnLanguge!.Code}/di${json["Id"]}.svg'),
          categoryBackgroundImagePath:
              '$dir/${StorageProvider.learnLanguge!.Code}/di${json["Id"]}.png',
          categoryBackgroundImage: File(
              '$dir/${StorageProvider.learnLanguge!.Code}/di${json["Id"]}.png'),
          categoryDialogCount: json["CategoryDialogCount"],
          totalCount: json["TotalDialogCount"],
          order: json["OrderId"],
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
          audio:
              '$path/$currentLanguage/${currentLanguage}_Di_${json["Id"]}.mp3');
}
