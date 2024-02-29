// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, avoid_function_literals_in_foreach_calls, curly_braces_in_flow_control_structures, unused_local_variable, avoid_print, prefer_interpolation_to_compose_strings

import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:patikmobile/api/static_variables.dart';
import 'package:patikmobile/models/dialog.dart' as dialog;
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
    if (database != null && database!.isOpen) return true;
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
      String dbPath = await getDbPath(lngName: lcid.Code);
      if (database == null || !database!.isOpen) {
        database = await openDatabase(dbPath);
        checkInformation = true;
      }
      if (database!.isOpen) {
        if (checkInformation == true) {
          Information infrm = await getInformation();
          String hash = infrm.lngHash!;
          StaticVariables.lngPlanType = infrm.lngPlanType!;
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
    if (lngName.isEmpty) {
      StorageProvider.learnLanguge ??= await StorageProvider.getLearnLanguage();
      lngName = StorageProvider.learnLanguge!.Code;
    }

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
    //list = await AppDbProvider().setWordAppLng(list);
    return list;
  }

  Future<List<WordListInformation>> getCategories(BuildContext context) async {
    var status = await reOpenDbConnection();
    if (!status) return [];

    String sql = """
Select w.*, (Select Count(*) from Words w1 where w1.Categories LIKE '%|' || w.Id || '|%') as CategoryWordCount,
(Select count(*) from Words w2 where w2.IsCategoryName != 1) as TotalWordCount
from Words w where w.IsCategoryName = 1 """;
    var res = await database!.rawQuery(sql);
    var liste =
        res.map((e) => WordListInformation.fromMap(e, context)).toList();
    return await AppDbProvider().setCategoryAppLng(liste);
  }

  Future<List<dialog.DialogListInformation>> getDialogCategories(
      BuildContext context) async {
    var status = await reOpenDbConnection();
    if (!status) return [];

    Directory dir = await getApplicationDocumentsDirectory();
    String sql = """
Select w.*, (Select Count(*) from Dialogs w1 where w1.Categories LIKE '%|' || w.Id || '|%') as CategoryDialogCount,
(Select count(*) from Dialogs w2 where w2.IsCategoryName != 1) as TotalDialogCount
from Dialogs w where w.IsCategoryName = 1 order by Id desc""";
    var res = await database!.rawQuery(sql);
    var liste = res
        .map((e) => dialog.DialogListInformation.fromMap(dir.path, e, context))
        .toList();
    return await AppDbProvider().setDialogCategoryAppLng(liste);
  }

  Future<List<dialog.DialogListDBInformation>> getDialogListSelectedCategories(
      BuildContext context,
      String id,
      String path,
      String currentLanguage) async {
    var status = await reOpenDbConnection();
    if (!status) return [];

    Directory dir = await getApplicationDocumentsDirectory();

    var res = await database!
        .rawQuery("Select * from Dialogs where Categories LIKE '%|$id|%'");
    var liste = res
        .map((e) =>
            dialog.DialogListDBInformation.fromMap(e, path, currentLanguage))
        .toList();
    return await AppDbProvider().setDialogAppLng(liste);
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

  Future<bool> addToLearnedBox(int dbId) async {
    try {
      var status = await reOpenDbConnection();
      if (!status) return false;
      await database!.insert(
        'WordStatistics',
        WordStatistics(
          wordId: dbId,
          learned: 1,
          repeat: 0,
          workHard: 0, // WorkHard sütununu 1 yap
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

  Future<bool> addToRepeatBox(int dbId) async {
    try {
      var status = await reOpenDbConnection();
      if (!status) return false;
      await database!.insert(
        'WordStatistics',
        WordStatistics(
          wordId: dbId,
          learned: 0,
          repeat: 1,
          workHard: 0, // WorkHard sütununu 1 yap
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

  Future<List<Word>> getRandomWordList(
      {String? dbId = "",
      bool withoutCategoryName = false,
      bool notInWordStatistics = true,
      int limit = 5}) async {
    var status = await reOpenDbConnection();
    if (!status) return [];

    String sqlQuery = """
    SELECT w.* FROM Words w
    ${notInWordStatistics ? "LEFT JOIN WordStatistics ws on w.Id = ws.WordId " : ""} 
    where 
    ${withoutCategoryName ? "w.IsCategoryName != 1" : "1=1"} 
    ${dbId!.isNotEmpty ? "and Categories LIKE '%|$dbId|%'" : ""}
    ${notInWordStatistics ? "and ws.WordId IS NULL" : ""} 
    ORDER BY RANDOM()
    ${limit > 0 ? "LIMIT $limit" : ""} 
    """;
    print(sqlQuery);
    var res = await database!.rawQuery(sqlQuery);

    List<Word> list = res.map((c) => Word.fromMap(c)).toList();
    list = await AppDbProvider().setWordAppLng(list);
    return list;
  }

  Future<List<Word>> getRandomStatisticsWordList(
      {String? dbId = "", int limit = 5, List<int>? ignoreIdList}) async {
    var status = await reOpenDbConnection();
    if (!status) return [];

    String ignoreIds = "";
    if (ignoreIdList != null && ignoreIdList.isNotEmpty) {
      ignoreIds = "and ws.WordId not in (${ignoreIdList.join(",")})";
    }

    String sqlQuery = """
    SELECT w.* FROM Words w
    JOIN WordStatistics ws on w.Id = ws.WordId
    where 
    w.IsCategoryName != 1 
    ${dbId!.isNotEmpty ? "and Categories LIKE '%|$dbId|%'" : ""}
    $ignoreIds
    ORDER BY RANDOM()
    ${limit > 0 ? "LIMIT $limit" : ""} 
    """;
    var res = await database!.rawQuery(sqlQuery);

    List<Word> list = res.map((c) => Word.fromMap(c)).toList();
    list = await AppDbProvider().setWordAppLng(list);
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

class AppDbProvider extends ChangeNotifier {
  static Database? database;
  bool? checkInformation;

  Future<bool> reOpenDbConnection() async {
    if (database != null && database!.isOpen) return true;
    if (StorageProvider.appLanguge!.Code.isNotEmpty) {
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
            prefs.setInt(StorageProvider.appLcidKey, lcid.LCID);
        } else
          result.status = true;
      }
    }
    return result;
  }

  getDbPath({String lngName = ""}) async {
    if (lngName.isEmpty) {
      StorageProvider.appLanguge ??= await StorageProvider.getAppLanguage();
      lngName = StorageProvider.appLanguge!.Code;
    }

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

  Future<List<Word>> setWordAppLng(List<Word> liste) async {
    var status = await reOpenDbConnection();
    if (!status) return [];

    String idList = liste.map((e) => e.id).toList().join(",");
    var res =
        await database!.rawQuery("Select * from Words where Id In ($idList)");

    res.forEach((c) => liste.firstWhere((r) => r.id == c["Id"]).wordAppLng =
        c["Word"] as String?);
    return liste;
  }

  Future<List<WordListInformation>> setCategoryAppLng(
      List<WordListInformation> liste) async {
    var status = await reOpenDbConnection();
    if (!status) return [];

    String idList = liste.map((e) => e.dbId).toList().join(",");
    var res =
        await database!.rawQuery("Select * from Words where Id In ($idList)");

    res.forEach((c) => liste
        .firstWhere((r) => r.dbId == c["Id"].toString())
        .categoryAppLngName = c["Word"] as String?);
    return liste;
  }

  Future<List<dialog.DialogListDBInformation>> setDialogAppLng(
      List<dialog.DialogListDBInformation> liste) async {
    var status = await reOpenDbConnection();
    if (!status) return [];

    String idList = liste.map((e) => e.id).toList().join(",");
    var res =
        await database!.rawQuery("Select * from Dialogs where Id In ($idList)");

    res.forEach((c) => liste.firstWhere((r) => r.id == c["Id"]).dialogAppLng =
        c["Word"] as String?);
    return liste;
  }

  Future<List<dialog.DialogListInformation>> setDialogCategoryAppLng(
      List<dialog.DialogListInformation> liste) async {
    var status = await reOpenDbConnection();
    if (!status) return [];

    String idList = liste.map((e) => e.dbId).toList().join(",");
    var res =
        await database!.rawQuery("Select * from Dialogs where Id In ($idList)");

    res.forEach((c) => liste
        .firstWhere((r) => r.dbId == c["Id"].toString())
        .categoryAppLngName = c["Word"] as String?);
    return liste;
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

  checkLanguage(int lcid) async {
    Lcid language = Languages.GetLngFromLCID(lcid);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageProvider.appLcidKey, lcid);
    await prefs.setString("language_name", language.Name!);
    StorageProvider.appLanguge = Languages.GetLngFromLCID(lcid);

    var path = await getDbPath(lngName: language.Code);

    return await File(path).exists();
  }
}
