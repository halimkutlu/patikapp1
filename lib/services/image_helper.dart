// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
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
    {double? height, double? width, BoxFit? boxFit = BoxFit.contain}) {
  Widget result = Icon(Icons.developer_board);
  if (lngPathImage) {
    var file = File('${StorageProvider.learnLanguageDir}/wrd_$id.svg');
    if (file.existsSync()) {
      result =
          SvgPicture.file(file, height: height, width: width, fit: boxFit!);
    }
  } else {
    result = SvgPicture.asset('assets/wordImages/wrd_$id.svg',
        height: height, width: width, fit: boxFit!);
  }

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
  } else {
    result = SvgPicture.asset('assets/dialogImages/di$id.svg',
        height: height, width: width);
  }

  return result;
}

ImageProvider getDialogBackground(String id, bool lngPathImage) {
  if (lngPathImage) {
    return FileImage(File('${StorageProvider.learnLanguageDir}/di$id.png'));
  }
  return AssetImage('assets/dialogBackgroundImages/di$id.png');
}

Future<Uint8List> getCategoryImageBytes(String id, bool lngPathImage) async {
  Uint8List result = Uint8List(0);
  if (lngPathImage) {
    var file = File('${StorageProvider.learnLanguageDir}/di$id.svg');
    if (file.existsSync()) {
      result = file.readAsBytesSync();
    }
  } else {
    var file = await rootBundle.load('assets/dialogImages/di$id.svg');
    result = file.buffer.asUint8List();
  }
  return result;
}
