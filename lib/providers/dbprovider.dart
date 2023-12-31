// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leblebiapp/providers/download_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class DbProvider extends ChangeNotifier {
  initData(BuildContext context) async {
    Future<void> _initDatabase() async {
      var dbDir = await getDatabasesPath();
      var dbPath = join(dbDir, "app.db");

// Delete any existing database:
      await deleteDatabase(dbPath);

// Create the writable database file from the bundled demo database file:
      ByteData data = await rootBundle.load("lib/db/tr-TR.db");
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes);
      var db = await openDatabase(
        dbPath,
        onOpen: (Database db) async {
          // Veritabanı açıldığında yapılacak işlemler
          print('Database opened');
        },
      );
      print(db);
    }
  }

  runProcess() async {
    // ZIP dosyasının yolu
    if (Platform.isAndroid) {
      await Permission.manageExternalStorage.request();
    } else {
      await Permission.storage.request();
    }
    var direct = File('/storage/emulated/0/Download/123456789_tr-TR.zip');

    // ZIP dosyasını çıkaran fonksiyon
    List<int> bytes = direct.readAsBytesSync();
    Archive archive = ZipDecoder().decodeBytes(bytes);

    // Çıkartılan dosyaları depolamak için geçici bir dizin oluştur
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    // ZIP dosyasındaki dosyaları çıkart
    for (ArchiveFile file in archive) {
      String fileName = '$tempPath/${file.name}';
      File(fileName)
        ..createSync(recursive: true)
        ..writeAsBytesSync(file.content);
    }

    // SQLite veritabanı dosyasının yolu
    String dbPath = '$tempPath/path/to/your/database.db';

    // SQLite veritabanını aç
    Database database = await openDatabase(
      dbPath,
      password: '123456789', // SQLite veritabanının şifresi
    );

    // SQLite sorgularını yapabilirsiniz
    List<Map<String, dynamic>> result =
        await database.rawQuery('SELECT * FROM your_table');
    print(result);

    // Veritabanını kapat
    await database.close();
  }
}
