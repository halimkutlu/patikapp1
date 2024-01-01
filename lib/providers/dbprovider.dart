// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, avoid_function_literals_in_foreach_calls

import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leblebiapp/providers/download_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class DbProvider extends ChangeNotifier {
  runProcess(String filename) async {
    // ZIP dosyasının yolu
    bool permissionStatus;
    final deviceInfo = await DeviceInfoPlugin().androidInfo;

    // Buna bakarsın kutlu benim emulator 30
    if (deviceInfo.version.sdkInt > 32) {
      //permissionStatus = await Permission.photos.request().isGranted;
      permissionStatus =
          await Permission.manageExternalStorage.request().isGranted;
    } else {
      //permissionStatus = await Permission.storage.request().isGranted;
      permissionStatus =
          await Permission.manageExternalStorage.request().isGranted;
    }

    //Seçilen Dosya kontrol edilir.
    final appDocDir = await getApplicationCacheDirectory();

    // // "PatikApp" klasörü varmı diye bakılır
    // final patikAppDir = Directory('${appDocDir.path}/PatikApp');
    // if (!await patikAppDir.exists()) {
    //   //Eğer dosya yoksa indirme işlemi yapılması gerekiyor
    //   return;
    // }

    final file = File('${appDocDir.path}/$filename.zip');

    // Dosya zaten var mı kontrol et
    if (await file.exists()) {
      //DOSYA VARSA OKUMA İŞLEMLERİ YAPILIR
      //ÖNCESİNDE CACHE DOSYASINDAN AKTARIM YAPILMASI GEREKİYOR.
      try {
        List<int> bytes = file.readAsBytesSync();
        Archive archive = ZipDecoder().decodeBytes(bytes);

        Directory dir = await getApplicationDocumentsDirectory();
        // final patikAppDir = Directory('${dir.path}/PatikApp').path;

        // ZIP dosyasındaki dosyaları çıkart
        for (ArchiveFile file in archive) {
          File tempFile = File('${dir.path}/${file.name}');

          tempFile
            ..createSync(recursive: true)
            ..writeAsBytesSync(file.content);
        }

        DbProvider dbProvider = DbProvider();
        dbProvider.readDb("tr-TR");
      } catch (e) {
        print(e);
      }
    } else {
      //TO DO DOSYA YOKSA İNDİRME İŞLEMİ YAPILIR
    }
  }

  Future<void> readDb(String filename) async {
    Directory dir = await getApplicationDocumentsDirectory();
    final patikAppDir = Directory('${dir.path}/$filename').path;
    final dbPath = File('${patikAppDir}/$filename.db').path;

    //SQLite veritabanını aç
    Database database = await openDatabase(dbPath);

    // Kullanıcı tablolarını al
    var tableNames = (await database.query('sqlite_master',
            where: 'type = ? AND name NOT LIKE ?',
            whereArgs: ['table', 'sqlite_%']))
        .map((row) => row['name'] as String)
        .where((tableName) =>
            tableName !=
            'android_metadata') // android_metadata tablosunu hariç tut
        .toList(growable: false);

    // Tablo isimlerini yazdır
    tableNames.forEach((tableName) {
      debugPrint(tableName);
    });

    // SQLite sorgularını yapabilirsiniz
    await database.rawQuery('SELECT * FROM Information');

    // Veritabanını kapat
    await database.close();
  }
}
