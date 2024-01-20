// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, avoid_function_literals_in_foreach_calls, curly_braces_in_flow_control_structures, unused_local_variable, avoid_print, prefer_interpolation_to_compose_strings

import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:patikmobile/models/information.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/models/word_statistics.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patikmobile/providers/deviceProvider.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';

class DbProvider extends ChangeNotifier {
  static Database? database;
  bool? checkInformation;

  runProcess(String filename) async {
    FileDownloadStatus result = FileDownloadStatus();
    result.status = false;
    result.message = "";

    bool permissionStatus;
    final phoneId = DeviceProvider.getPhoneId();

    await Permission.manageExternalStorage.request().isGranted;

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
      } finally {
        await file.delete();
      }

      result.status = true;
      result.message = "İndirme işlemi başarılı";
      return result;
    }
  }

  Future<bool> reOpenDbConnection() async {
    if (database!.isOpen) return true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FileDownloadStatus result = FileDownloadStatus();

    if (StorageProvider.learnLanguge!.Code.isNotEmpty) {
      String dbPath = await getDbPath();
      if (database == null || !database!.isOpen) {
        database = await openDatabase(dbPath);
        return database!.isOpen;
      }
    }
    return false;
  }

  Future<FileDownloadStatus> openDbConnection(Lcid lcid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FileDownloadStatus result = FileDownloadStatus();
    if (lcid.Code.isNotEmpty) {
      String dbPath = await getDbPath();
      if (database == null || !database!.isOpen) {
        database = await openDatabase(dbPath);
        checkInformation = true;
      }
      if (database!.isOpen) {
        if (checkInformation == true) {
          Information infrm = await getInformation();
          String hash = infrm.lngHash!;
          String phoneId = DeviceProvider.getPhoneId();
          result.status =
              await FlutterBcrypt.verify(password: phoneId, hash: hash);
          if (result.status)
            prefs.setInt(StorageProvider.learnLcidKey, lcid.LCID);
        } else
          result.status = true;
      }
    }
    return result;
  }

  getDbPath({String lngName = ""}) async {
    Lcid language = await StorageProvider.getLearnLanguage();
    if (lngName.isEmpty) lngName = language.Code;

    Directory dir = await getApplicationDocumentsDirectory();
    final patikAppDir = Directory('${dir.path}/$lngName').path;
    String dbPath = File('$patikAppDir/$lngName.db').path;

    return dbPath;
  }

  ifConnectionAlive() {
    return database != null ? database!.isOpen : false;
  }

  Future<void> closeDbConnection() async {
    if (database != null && database!.isOpen) await database!.close();
  }

  Future<List<Word>> getWordList({bool withoutCategoryName = false}) async {
    var status = await reOpenDbConnection();
    if (!status) return [];

    var res = await database!.rawQuery('Select * from Words' +
        (withoutCategoryName ? ' where IsCategoryName != 1' : ''));

    List<Word> list = res.map((c) => Word.fromMap(c)).toList();
    return list;
  }

  Future<bool> addToWorkHardBox(int dbId) async {
    try {
      var status = await reOpenDbConnection();
      if (!status) return false;
      await database!.insert(
        'WordStatistics',
        WordStatistics(
          wordId: dbId,
          learned: 0,
          repeat: 0,
          workHard: 1, // WorkHard sütununu 1 yap
          successCount: 0,
          errorCount: 0,
        ).toMap(),
        conflictAlgorithm:
            ConflictAlgorithm.replace, // Eğer aynı WordId varsa güncelle
      );
      return true;
    } catch (e) {
      print("Hata oluştu: $e");
      return false;
    }
  }

  Future<bool> updateWorkHard(int dbId) async {
    try {
      var status = await reOpenDbConnection();
      if (!status) return false;

      await database!.update(
        'WordStatistics',
        {'WorkHard': 0}, // Güncellenen değerleri belirt
        where: 'WordId = ?',
        whereArgs: [dbId],
      );

      return true;
    } catch (e) {
      print("Hata oluştu: $e");
      return false;
    }
  }

  Future<Information> getInformation() async {
    var status = await reOpenDbConnection();
    if (!status) return Information();

    var res = await database!.query("Information", columns: [
      'LCID',
      'Code',
      'Version',
      'Directory',
      'LngPlanType',
      'LngHash',
    ]);

    List<Information> list = res.map((c) => Information.fromMap(c)).toList();
    return list.first;
  }

  Future<List<WordStatistics>> getWordStatisticsList() async {
    var status = await reOpenDbConnection();
    if (!status) return [];

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

  checkLanguage(int lcid) async {
    Lcid language = Languages.GetLngFromLCID(lcid);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageProvider.learnLcidKey, lcid);
    await prefs.setString("CurrentLanguageName", language.Name!);
    StorageProvider.learnLanguge = Languages.GetLngFromLCID(lcid);

    var path = await getDbPath(lngName: language.Code);

    return await File(path).exists();
  }
}
