// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leblebiapp/assets/mainColors.dart';
import 'package:leblebiapp/locale/Messages.dart';
import 'package:leblebiapp/pages/splashScreen.dart';
import 'package:leblebiapp/providers/dbprovider.dart';
import 'package:leblebiapp/providers/introductionPageProvider.dart';
import 'package:leblebiapp/providers/loginProvider.dart';
import 'package:leblebiapp/providers/registerProvider.dart';
import 'package:leblebiapp/providers/splashScreenProvider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sizer/sizer.dart';

//telefona otomatik klasör oluşturucak
//tr_TR yoksa uyarı çıkıcak, indirme ile zip gelecek
//seçilen zipi açarak dizine atıcak
//hangi dil seçilirse db bağlantısı o an kurulacak
//stream ile dosya indirme
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
  ChangeNotifierProvider<DbProvider>(create: (_) => DbProvider()),
];

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // downloadFile("https://lingobetik.com.tr/Downloads/GetLngFileStream",
    //     filename: 'tr-TR');
    // runTheProcedures();
    super.initState();
  }

  runTheProcedures() async {
    var dbProvider = DbProvider();
    await dbProvider.openDbConnection("tr-TR");
    await dbProvider.getWordList();
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
