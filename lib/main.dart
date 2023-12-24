import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leblebiapp/assets/mainColors.dart';
import 'package:leblebiapp/locale/Messages.dart';
import 'package:leblebiapp/pages/splashScreen.dart';
import 'package:leblebiapp/providers/introductionPageProvider.dart';
import 'package:leblebiapp/providers/loginProvider.dart';
import 'package:leblebiapp/providers/registerProvider.dart';
import 'package:leblebiapp/providers/splashScreenProvider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<SplashScreenProvider>(
      create: (_) => SplashScreenProvider()),
  ChangeNotifierProvider<IntroductionPageProvider>(
      create: (_) => IntroductionPageProvider()),
  ChangeNotifierProvider<LoginProvider>(create: (_) => LoginProvider()),
  ChangeNotifierProvider<RegisterProvider>(create: (_) => RegisterProvider()),
];

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Database _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    // Veritabanının yolunu al
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'my_database.db');
    print(path);

    // Veritabanını kontrol et ve oluştur veya aç
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        print("db oluşturuldu");
        // Veritabanı oluşturma işlemleri
        await db.execute('''
          CREATE TABLE my_table (
            id INTEGER PRIMARY KEY,
            name TEXT,
            age INTEGER
          )
        ''');
        // Örnek bir kayıt ekle
        await db.rawInsert(
            "INSERT INTO my_table (name, age) VALUES (?, ?)", ['test', 12]);
      },
      onOpen: (Database db) async {
        // Veritabanı açıldığında yapılacak işlemler
        print('Database opened');
        var result = await db.query("my_table");
        print(await db.rawQuery("Select count(*) from my_table"));
        print(result);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          translations: LocaleString(),
          locale: Locale('de', 'DE'),
          title: 'Flutter Demo',
          theme: ThemeData(
            scaffoldBackgroundColor: MainColors.backgroundColor,
            primarySwatch: Colors.blue,
          ),
          home: SplashScreen());
    });
  }
}
