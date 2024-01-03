// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, avoid_function_literals_in_foreach_calls, curly_braces_in_flow_control_structures, unused_local_variable, avoid_print

import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:patikmobile/api/static_variables.dart';
import 'package:patikmobile/models/information.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/models/word_statistics.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class DbProvider extends ChangeNotifier {
  Database? database;

  runProcess(String filename) async {
    FileDownloadStatus result = FileDownloadStatus();
    result.status = false;
    result.message = "";

    bool permissionStatus;
    final deviceInfo = await DeviceInfoPlugin().androidInfo;

    if (deviceInfo.version.sdkInt > 32) {
      permissionStatus =
          await Permission.manageExternalStorage.request().isGranted;
    } else {
      permissionStatus =
          await Permission.manageExternalStorage.request().isGranted;
    }

    final appDocDir = await getApplicationCacheDirectory();

    final file = File('${appDocDir.path}/$filename.zip');

    if (await file.exists()) {
      try {
        List<int> bytes = file.readAsBytesSync();
        Archive archive = ZipDecoder().decodeBytes(bytes);

        Directory dir = await getApplicationDocumentsDirectory();

        for (ArchiveFile file in archive) {
          File tempFile = File('${dir.path}/${file.name}');

          tempFile
            ..createSync(recursive: true)
            ..writeAsBytesSync(file.content);
        }
      } catch (e) {
        result.message =
            "İndirme işlemleri sırasında bir hata oluştu. Lütfen tekrar deneyiniz";
        print(e);
        return result;
      }

      result.status = true;
      result.message = "İndirme işlemi başarılı";
      return result;
    }
  }

  Future<FileDownloadStatus> openDbConnection(String filename) async {
    FileDownloadStatus result = FileDownloadStatus();
    if (filename.isNotEmpty) {
      StaticVariables.LangName = filename;

      String dbPath = await getDbPath();
      if (database != null && database!.isOpen) {
        await database!.close();
      }

      database = await openDatabase(dbPath);
      if (database!.isOpen) {
        result.status = true;
      }
    }
    return result;
  }

  getDbPath() async {
    Directory dir = await getApplicationDocumentsDirectory();
    final patikAppDir =
        Directory('${dir.path}/${StaticVariables.LangName}').path;
    String dbPath = File('$patikAppDir/${StaticVariables.LangName}.db').path;

    return dbPath;
  }

  ifConnectionAlive() {
    return database != null ? database!.isOpen : false;
  }

  Future<void> closeDbConnection() async {
    if (database != null && database!.isOpen) await database!.close();
  }

  Future<List<Word>> getWordList() async {
    var res = await database!.query('Words', columns: [
      'Id',
      'Word',
      'WordA',
      'WordT',
      'IsCategoryName',
      'Categories',
      'Activities',
      'OrderId'
    ]);

    List<Word> list = res.map((c) => Word.fromMap(c)).toList();
    return list;
  }

  Future<List<Information>> getInformationList() async {
    var res = await database!.query("Information", columns: [
      'LCID',
      'Code',
      'Version',
      'Directory',
      'LngPlanType',
      'LngHash',
    ]);

    List<Information> list = res.map((c) => Information.fromMap(c)).toList();
    return list;
  }

  Future<List<WordStatistics>> getWordStatisticsList() async {
    var res = await database!.query('WordStatistics', columns: [
      'WordId',
      'Learned',
      'Repeat',
      'WorkHard',
      'SuccessCount',
      'ErrorCount',
    ]);

    List<WordStatistics> list =
        res.map((c) => WordStatistics.fromMap(c)).toList();
    return list;
  }
}
