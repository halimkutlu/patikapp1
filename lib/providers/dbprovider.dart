// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, avoid_function_literals_in_foreach_calls, curly_braces_in_flow_control_structures, unused_local_variable, avoid_print, prefer_interpolation_to_compose_strings, null_argument_to_non_null_type, avoid_init_to_null, prefer_const_constructors

import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patikmobile/api/api_repository.dart';
import 'package:patikmobile/api/api_urls.dart';
import 'package:patikmobile/api/static_variables.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/models/dialog.dart' as dialog;
import 'package:patikmobile/models/http_response.model.dart';
import 'package:patikmobile/models/information.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/models/languageSizeModel.dart';
import 'package:patikmobile/models/user_roles.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/models/word_statistics.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/pages/select_learn_language.dart';
import 'package:patikmobile/providers/apiService.dart';
import 'package:patikmobile/providers/deviceProvider.dart';
import 'package:patikmobile/providers/download_file.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as db;
import 'package:flutter_bcrypt/flutter_bcrypt.dart';
import 'package:sqflite/sqlite_api.dart';
import 'dart:math' as math;

class DbClass {
  late db.Database? database;
  late bool open;
  DbClass(this.open, {this.database});
}

extension FancyIterable on Iterable<int> {
  int get max => reduce(math.max);

  int get min => reduce(math.min);
}

const List<int> premiumList = [UserRole.admin, UserRole.premium, UserRole.qr];
String get ifPremium =>
    StaticVariables.Roles.any((element) => premiumList.contains(element))
        ? ""
        : "and IsFree=1";

String ifPremiumx(String c) =>
    StaticVariables.Roles.any((element) => premiumList.contains(element))
        ? ""
        : "and $c.IsFree=1";

Future<DbClass> openDatabase(String path) async {
  final file = File(path);
  DbClass sonuc = DbClass(false);
  if (!file.existsSync()) {
    await Get.defaultDialog(title: "Error", middleText: "Db file not found");
    return sonuc;
  }
  try {
    db.Database dbase = await db.openDatabase(path);
    sonuc = DbClass(dbase.isOpen, database: dbase);
  } catch (e) {
    await Get.defaultDialog(title: "Error", middleText: e.toString());
  }
  return sonuc;
}

abstract class DbProviderBase extends ChangeNotifier {
  runProcess(BuildContext context, String filename);
  //ifConnectionAlive();
  Future<void> closeDb();
  Future<bool> openDbConnection({bool reopen = false, Lcid? lcid = null});
  Future<bool> openDb(Lcid lcid);
}

class LearnDbProvider extends DbProviderBase {
  static db.Database? database;

  @override
  runProcess(BuildContext context, String filename) async {
    FileDownloadStatus result = FileDownloadStatus();
    result.status = false;
    result.message = "";

    bool permissionStatus;
    final phoneId = DeviceProvider.getPhoneId();

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
        result.message = AppLocalizations.of(context).translate("177");
        print(e);
        return result;
      } finally {
        await file.delete();
      }

      result.status = true;
      result.message = AppLocalizations.of(context).translate("176");
      return result;
    }
  }

  @override
  Future<bool> openDbConnection(
      {bool reopen = false, Lcid? lcid = null}) async {
    if (!reopen && database != null && (database?.isOpen ?? false)) return true;
    lcid = lcid ?? StorageProvider.learnLanguge;
    if (lcid != null && lcid.Code.isNotEmpty) {
      return await openDb(lcid);
    }
    return false;
  }

 @override
  Future<List<LngFileSizeResponse>> getLanguageFileSize() async {
   List<LngFileSizeResponse> emptyList = List<LngFileSizeResponse>.empty(growable: true);

    final apirepository = APIRepository();
    httpSonucModel lngList =
        await apirepository.get(controller: getSizeOfLanguages);
    if (lngList.success!) {
      notifyListeners();
      return LngFileSizeResponse.listFromJson(lngList.data);
    }
    else{
      return emptyList;
    }
  }

  @override
  Future<bool> openDb(Lcid lcid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("selectedWords", []);
    bool result = false;
    if (lcid.Code.isNotEmpty) {
      String dbPath = await getDbPath(lngName: lcid.Code);
      var dbase = await openDatabase(dbPath);
      database = dbase.database;
      if (dbase.open) {
        Information infrm = await getInformation(isOpen: true);
        String hash = infrm.lngHash!;
        StaticVariables.lngPlanType = infrm.lngPlanType!;
        String phoneId = DeviceProvider.getPhoneId();
        result = await FlutterBcrypt.verify(password: phoneId, hash: hash);
        if (result) prefs.setInt(StorageProvider.learnLcidKey, lcid.LCID);

        if (StaticVariables.Roles.any(
            (element) => element == UserRole.premium)) {
          Information infrm = await getInformation();
          if (infrm.lngPlanType == LngPlanType.Free) {
            try {
              List<String> scripts = await getPremiumContent();
              if (scripts.isNotEmpty) runScript(scripts);
            } catch (e) {
              print(e);
            }
          }
        }
      }
    }

    return result;
  }

  // @override
  // ifConnectionAlive() {
  //   return database?.isOpen ?? false;
  // }

  @override
  Future<void> closeDb() async {
    if (database != null && (database?.isOpen ?? false))
      await database!.close();
  }

  Future<List<String>> getPremiumContent() async {
    ApiService apiService = ApiService(baseUrl: BASE_URL);

    //success
    var info = await getInformation();
    if (info.lngPlanType == LngPlanType.Free) {
      var data = {"LCID": info.lcid, "Version": "1.0.0", "Code": info.code};
      var response = await apiService.post(getUpgradeSqlStrings, data);
      if (response.success!) {
        // Eğer dönüş başarılıysa ve veri varsa, dönüştürüp geri döndür
        if (response.data != null && response.data["Scripts"] is List) {
          List<String> sqlStrings = response.data["Scripts"]
              .map<String>((e) => e.toString())
              .toList();
          return sqlStrings;
        } else {
          // Veri yoksa veya beklenen formatta değilse boş bir liste döndür
          return [];
        }
      }
    }

    // Diğer durumlarda veya başarısızlık durumunda null döndür
    return [];
  }

  getDbPath({String lngName = ""}) async {
    if (lngName.isEmpty) {
      StorageProvider.learnLanguge ??= await StorageProvider.getLearnLanguage();
      lngName = StorageProvider.learnLanguge!.Code;
    }

    Directory dir = await getApplicationDocumentsDirectory();
    final directory = Directory('${dir.path}/$lngName');
    if (directory.existsSync()) {
      final file = File('${directory.path}/$lngName.db');
      if (file.existsSync()) return file.path;
    }
    return "";
  }

  Future<List<Word>> getWordList({bool withoutCategoryName = false}) async {
    var status = await openDbConnection();
    if (!status) return [];
    var res = await database!.rawQuery('Select * from Words' +
        (withoutCategoryName ? ' where IsCategoryName != 1 $ifPremium' : ''));

    List<Word> list = res.map((c) => Word.fromMap(c)).toList();
    //list = await AppDbProvider().setWordAppLng(list);
    return list;
  }

  Future<List<WordListInformation>> getCategories(BuildContext context) async {
    var status = await openDbConnection();
    if (!status) return [];

    Directory dir = await getApplicationDocumentsDirectory();
    String sql = """
Select w.*, (Select Count(*) from Words w1 where w1.Categories LIKE '%|' || w.Id || '|%' ${ifPremiumx("w1")}) as CategoryWordCount,
(Select count(*) from Words w2 where w2.IsCategoryName != 1 ${ifPremiumx("w2")}) as TotalWordCount,
(Select Count(*) from Words w3 where w3.IsCategoryName != 1 ${ifPremiumx("w3")} and w3.Categories LIKE '%|' || w.Id || '|%' and w3.Id IN (Select ws.WordId from WordStatistics ws)) as LearnedWordsCount
from Words w where w.IsCategoryName = 1 ${ifPremiumx("w")}""";
    var res = await database!.rawQuery(sql);
    var liste =
        res.map((e) => WordListInformation.fromMap(e, context, true)).toList();
    return await AppDbProvider().setCategoryAppLng(liste);
  }

  Future<List<dialog.DialogListInformation>> getDialogCategories(
      BuildContext context) async {
    var status = await openDbConnection();
    if (!status) return [];

    Directory dir = await getApplicationDocumentsDirectory();
    String sql = """
Select w.*, (Select Count(*) from Dialogs w1 where w1.Categories LIKE '%|' || w.Id || '|%') as CategoryDialogCount,
(Select count(*) from Dialogs w2 where w2.IsCategoryName != 1) as TotalDialogCount
from Dialogs w where w.IsCategoryName = 1 order by Id desc""";
    var res = await database!.rawQuery(sql);
    var liste = res
        .map((e) => dialog.DialogListInformation.fromMap(e, context))
        .toList();
    return await AppDbProvider().setDialogCategoryAppLng(liste);
  }

  Future<List<dialog.DialogListDBInformation>> getDialogListSelectedCategories(
      BuildContext context,
      String id,
      String path,
      String currentLanguage) async {
    var status = await openDbConnection();
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
      var status = await openDbConnection();
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
      var status = await openDbConnection();
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
      var status = await openDbConnection();
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
      var status = await openDbConnection();
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

  Future<Information> getInformation({bool isOpen = false}) async {
    var status = isOpen || await openDbConnection();
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
    var status = await openDbConnection();
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

  Future<List<Word>> getWordListById(String? dbId) async {
    var status = await openDbConnection();
    if (!status) return [];

    var res = await database!.rawQuery(
        "Select * from Words where Categories LIKE '%|$dbId|%' $ifPremium");

    List<Word> list = res.map((c) => Word.fromMap(c)).toList();
    list = await AppDbProvider().setWordAppLng(list);
    return list;
  }

  Future<List<Word>> getRandomWordList(
      {String? dbId = "",
      bool withoutCategoryName = false,
      bool notInWordStatistics = true,
      int limit = 5}) async {
    var status = await openDbConnection();
    if (!status) return [];

    String sqlQuery = """
    SELECT w.* FROM Words w
    ${notInWordStatistics ? "LEFT JOIN WordStatistics ws on w.Id = ws.WordId " : ""} 
    where 
    ${withoutCategoryName ? "w.IsCategoryName != 1" : "1=1"} 
    ${dbId!.isNotEmpty ? "and Categories LIKE '%|$dbId|%'" : ""}
    ${notInWordStatistics ? "and ws.WordId IS NULL" : ""}
    ${ifPremiumx("w")}
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
    var status = await openDbConnection();
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
    ${ifPremiumx("w")}
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

  checkLearnLanguage(int lcid) async {
    Lcid language = Languages.GetLngFromLCID(lcid);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageProvider.learnLcidKey, lcid);
    await prefs.setString("LearnLanguageName", language.Name!);
    StaticVariables.token = prefs.getString("Token")!;
    StorageProvider.learnLanguge = Languages.GetLngFromLCID(lcid);

    var path = await getDbPath(lngName: language.Code);

    return await File(path).exists();
  }

  Future<bool> runScript(List<String> scripts) async {
    if (scripts.isEmpty) return false;
    try {
      for (var script in scripts) {
        await database!.rawInsert(script);
      }
    } catch (e) {
      print("Error executing script: $e");
      return false;
    }
    return true;
  }

  getLearnLanguage(BuildContext context) async {
    final apirepository = APIRepository();
    httpSonucModel lngList =
        await apirepository.get(controller: learnLanguageUrl);
    if (lngList.success!) {
      Languages.fromJson(lngList.data);
      notifyListeners();
    }
  }

  Future<FileDownloadStatus> startProcessOfDownloadLearnLanguage(
      BuildContext context,
      DbProviderBase dbProvider,
      Lcid lcid,
      bool lernLng,
      void Function(int, int)? onReceiveProgress) async {
    //DbProvider dbProvider = DbProvider();
    FileDownloadStatus processResult = FileDownloadStatus();
    processResult.status = false;

    if (lcid.Code.isNotEmpty) {
      notifyListeners();

      //DOSYA İNDİRME İŞLEMİ YAPILIR.
      FileDownloadStatus resultDownloadFile = await downloadFile(
          "GetLngFileStream", context,
          lcid: lcid.LCID, onReceiveProgress: onReceiveProgress);

      if (resultDownloadFile.status) {
        //DOSYA İNDRİME İŞLEMİ BAŞARILI İSE DOSYAYI CACHEDEN ALARAK TELEFONA ÇIKARTMA İŞLEMİ YAPILIR
        FileDownloadStatus result =
            await dbProvider.runProcess(context, lcid.Code);
        if (result.status == false) {
          notifyListeners();
          processResult.status = false;
          return processResult;
        } else {
          //EĞER DOSYA ÇIKARTMA İŞLEMİ BAŞARILI İSE
          await closeDb();
          FileDownloadStatus dbresult = FileDownloadStatus();
          dbresult.status = await openDb(lcid);
          if (dbresult.status) {
            processResult.status = true;
          } else {
            processResult.status = false;
          }
          notifyListeners();
          return processResult;
        }
      } else {
        processResult.status = false;
        processResult.message = resultDownloadFile.message;
        notifyListeners();
        return processResult;
      }
    }
    notifyListeners();
    return processResult;
  }
}

class AppDbProvider extends DbProviderBase {
  static Database? database;
  bool? checkInformation;

  @override
  runProcess(BuildContext context, String filename) async {
    FileDownloadStatus result = FileDownloadStatus();
    result.status = false;
    result.message = "";

    bool permissionStatus;
    final phoneId = DeviceProvider.getPhoneId();

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
        result.message = AppLocalizations.of(context).translate("177");
        print(e);
        return result;
      } finally {
        await file.delete();
      }

      result.status = true;
      result.message = AppLocalizations.of(context).translate("176");
      return result;
    }
  }

  @override
  Future<List<LngFileSizeResponse>> getLanguageFileSize() async {
   List<LngFileSizeResponse> emptyList = List<LngFileSizeResponse>.empty(growable: true);

    final apirepository = APIRepository();
    httpSonucModel lngList =
        await apirepository.get(controller: getSizeOfLanguages);
    if (lngList.success!) {
      notifyListeners();
      return LngFileSizeResponse.listFromJson(lngList.data);
    }
    else{
      return emptyList;
    }
  }

  @override
  Future<bool> openDbConnection(
      {bool reopen = false, Lcid? lcid = null}) async {
    if (!reopen && database != null && (database?.isOpen ?? false)) return true;
    lcid = lcid ?? StorageProvider.appLanguge;
    if (lcid != null && lcid.Code.isNotEmpty) {
      return await openDb(lcid);
    }
    return false;
  }

  @override
  Future<bool> openDb(Lcid lcid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool result = false;
    if (lcid.Code.isNotEmpty) {
      String dbPath = await getDbPath(lngName: lcid.Code);
      var dbase = await openDatabase(dbPath);
      database = dbase.database;
      if (dbase.open) {
        Information infrm = await getInformation(isOpen: true);
        String hash = infrm.lngHash!;
        String phoneId = DeviceProvider.getPhoneId();
        result = await FlutterBcrypt.verify(password: phoneId, hash: hash);
        if (result) prefs.setInt(StorageProvider.appLcidKey, lcid.LCID);

        if (StaticVariables.Roles.any(
            (element) => element == UserRole.premium)) {
          if (infrm.lngPlanType == LngPlanType.Free) {
            try {
              List<String> scripts = await getPremiumContent();
              if (scripts.isNotEmpty) runScript(scripts);
            } catch (e) {
              print(e);
            }
          }
        }
      }
    }
    return result;
  }

  // @override
  // ifConnectionAlive() {
  //   return database?.isOpen ?? false;
  // }

  @override
  Future<void> closeDb() async {
    if (database != null && (database?.isOpen ?? false))
      await database!.close();
  }

  Future<List<String>> getPremiumContent() async {
    ApiService apiService = ApiService(baseUrl: BASE_URL);

    //success
    var info = await getInformation();
    if (info.lngPlanType == LngPlanType.Free) {
      var data = {"LCID": info.lcid, "Version": "1.0.0", "Code": info.code};
      var response = await apiService.post(getUpgradeSqlStrings, data);
      if (response.success!) {
        // Eğer dönüş başarılıysa ve veri varsa, dönüştürüp geri döndür
        if (response.data != null && response.data["Scripts"] is List) {
          List<String> sqlStrings = response.data["Scripts"]
              .map<String>((e) => e.toString())
              .toList();
          return sqlStrings;
        } else {
          // Veri yoksa veya beklenen formatta değilse boş bir liste döndür
          return [];
        }
      }
    }

    // Diğer durumlarda veya başarısızlık durumunda null döndür
    return [];
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

  Future<List<Word>> setWordAppLng(List<Word> liste) async {
    var status = await openDbConnection();
    if (!status) return [];

    String idList = liste.map((e) => e.id).toList().join(",");
    var res = await database!
        .rawQuery("Select * from Words where Id In ($idList) $ifPremium");

    res.forEach((c) => liste.firstWhere((r) => r.id == c["Id"]).wordAppLng =
        c["Word"] as String?);
    return liste;
  }

  Future<List<WordListInformation>> setCategoryAppLng(
      List<WordListInformation> liste) async {
    var status = await openDbConnection();
    if (!status) return [];

    String idList = liste.map((e) => e.dbId).toList().join(",");
    var res = await database!
        .rawQuery("Select * from Words where Id In ($idList) $ifPremium");

    res.forEach((c) => liste
        .firstWhere((r) => r.dbId == c["Id"].toString())
        .categoryAppLngName = c["Word"] as String?);
    return liste;
  }

  Future<List<dialog.DialogListDBInformation>> setDialogAppLng(
      List<dialog.DialogListDBInformation> liste) async {
    var status = await openDbConnection();
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
    var status = await openDbConnection();
    if (!status) return [];

    String idList = liste.map((e) => e.dbId).toList().join(",");
    var res =
        await database!.rawQuery("Select * from Dialogs where Id In ($idList)");

    res.forEach((c) => liste
        .firstWhere((r) => r.dbId == c["Id"].toString())
        .categoryAppLngName = c["Word"] as String?);
    return liste;
  }

  Future<Information> getInformation({bool isOpen = false}) async {
    var status = isOpen || await openDbConnection();
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

  checkAppLanguage(int lcid) async {
    Lcid language = Languages.GetLngFromLCID(lcid);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageProvider.appLcidKey, lcid);
    await prefs.setString("AppLanguageName", language.Name!);
    StorageProvider.appLanguge = Languages.GetLngFromLCID(lcid);

    var path = await getDbPath(lngName: language.Code);

    return await File(path).exists();
  }

  Future<bool> runScript(List<String> scripts) async {
    if (scripts.isEmpty) return false;
    try {
      for (var i = 0; i < scripts.length; i++) {
        await database!.rawQuery(scripts[i]);
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  setUseLanguage(Lcid language, BuildContext context, bool dashboard) {
    StorageProvider.updateLanguage(context, language);
    notifyListeners();
    //Navigator.pop(context);
    CustomAlertDialogOnlyConfirm(context, () {
      if (dashboard) {
        Navigator.pop(context);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Dashboard(0)));
      } else {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => SelectLearnLanguage()));
      }

      notifyListeners();
    },
        AppLocalizations.of(context).translate("164"),
        AppLocalizations.of(context).translate("168"),
        ArtSweetAlertType.success,
        AppLocalizations.of(context).translate("159"));
  }

  Future<FileDownloadStatus> startProcessOfDownloadLearnLanguage(
      BuildContext context,
      DbProviderBase dbProvider,
      Lcid lcid,
      bool lernLng,
      void Function(int, int)? onReceiveProgress) async {
    //DbProvider dbProvider = DbProvider();
    FileDownloadStatus processResult = FileDownloadStatus();
    processResult.status = false;

    if (lcid.Code.isNotEmpty) {
      notifyListeners();

      //DOSYA İNDİRME İŞLEMİ YAPILIR.
      FileDownloadStatus resultDownloadFile = await downloadFile(
          "GetLngFileStream", context,
          lcid: lcid.LCID, onReceiveProgress: onReceiveProgress);

      if (resultDownloadFile.status) {
        //DOSYA İNDRİME İŞLEMİ BAŞARILI İSE DOSYAYI CACHEDEN ALARAK TELEFONA ÇIKARTMA İŞLEMİ YAPILIR
        FileDownloadStatus result =
            await dbProvider.runProcess(context, lcid.Code);
        if (result.status == false) {
          notifyListeners();
          processResult.status = false;
          return processResult;
        } else {
          //EĞER DOSYA ÇIKARTMA İŞLEMİ BAŞARILI İSE
          await closeDb();
          FileDownloadStatus dbresult = FileDownloadStatus();
          dbresult.status = await openDb(lcid);
          if (dbresult.status) {
            processResult.status = true;
          } else {
            processResult.status = false;
          }
          notifyListeners();
          return processResult;
        }
      } else {
        processResult.status = false;
        processResult.message = resultDownloadFile.message;
        notifyListeners();
        return processResult;
      }
    }
    notifyListeners();
    return processResult;
  }
}
