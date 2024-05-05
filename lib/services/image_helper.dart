// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patikmobile/providers/storageProvider.dart';

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

Widget getWordImage(String id, bool lngPathImage,
    {double? height, double? width}) {
  Widget result = Icon(Icons.developer_board);
  if (lngPathImage) {
    var file = File('${StorageProvider.learnLanguageDir}/wrd_$id.svg');
    if (file.existsSync()) {
      result = SvgPicture.file(file, height: height, width: width);
    }
  }

  result = Image.asset('assets/wordImages/wrd_$id.svg',
      height: height,
      width: width,
      errorBuilder: (ctx, error, stackTrace) => Icon(Icons.developer_board));

  return result;
}

Widget getDialogImage(String id, bool lngPathImage,
    {double? height, double? width}) {
  Widget result = Icon(Icons.developer_board);
  if (lngPathImage) {
    var file = File('${StorageProvider.learnLanguageDir}/di$id.svg');
    if (file.existsSync()) {
      result = SvgPicture.file(file, height: height, width: width);
    }
  }

  result = Image.asset('assets/dialogImages/di$id.svg',
      height: height,
      width: width,
      errorBuilder: (ctx, error, stackTrace) => Icon(Icons.developer_board));

  return result;
}

ImageProvider getDialogBackground(String id, bool lngPathImage) {
  if (lngPathImage) {
    return FileImage(File('${StorageProvider.learnLanguageDir}/di$id.png'));
  }
  return AssetImage('assets/dialogBackgroundImages/di$id.png');
}
