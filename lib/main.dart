// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/ChangeLanguage.dart';
import 'package:patikmobile/locale/Messages.dart';
import 'package:patikmobile/locale/app_localization_delegate.dart';
import 'package:patikmobile/pages/splashScreen.dart';
import 'package:patikmobile/providers/changePasswordProvider.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:patikmobile/providers/deviceProvider.dart';
import 'package:patikmobile/providers/introductionPageProvider.dart';
import 'package:patikmobile/providers/loginProvider.dart';
import 'package:patikmobile/providers/mainPageProvider.dart';
import 'package:patikmobile/providers/dashboardProvider.dart';
import 'package:patikmobile/providers/registerProvider.dart';
import 'package:patikmobile/providers/splashScreenProvider.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

//indirilen dilin kayıt edilmesi (tekrar uygulama açıldığında o dilden devam edicek)
//progress indicator

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBFDNgEQpj6uQg_cIGYzUIBM3p7cEijcog',
        appId: '1:587524623446:android:4673d988efc27735a57ff7',
        messagingSenderId: '',
        projectId: 'patikmobile',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
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
  ChangeNotifierProvider<DashboardProvider>(create: (_) => DashboardProvider()),
  ChangeNotifierProvider<ChangePasswordProvider>(
      create: (_) => ChangePasswordProvider()),
  ChangeNotifierProvider<MainPageProvider>(create: (_) => MainPageProvider()),
];

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    StorageProvider.load();
    DeviceProvider.getPhoneId();
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
          //translations: LocaleString(),
          //locale: const Locale('hy', 'HW'), //Get.locale,
          title: 'Flutter Demo',
          theme: ThemeData(
            scaffoldBackgroundColor: MainColors.backgroundColor,
            primarySwatch: Colors.blue,
          ),
          // Localization delegates
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // Supported locales for this app
          supportedLocales: const [
            Locale('ar', 'EG'),
            Locale('bg', 'BG'),
            Locale('bs-Latn', 'BA'),
            Locale('de', 'DE'),
            Locale('el', 'GR'),
            Locale('en', 'US'),
            Locale('es', 'ES'),
            Locale('fa', 'IR'),
            Locale('fr', 'FR'),
            Locale('hy', 'AM'),
            Locale('hy', 'AW'),
            Locale('it', 'IT'),
            Locale('ja', 'JP'),
            Locale('ka', 'GE'),
            Locale('kb', 'KR'),
            Locale('mk', 'MK'),
            Locale('nl', 'NL'),
            Locale('pl', 'PL'),
            Locale('pt', 'BR'),
            Locale('pt', 'PT'),
            Locale('ru', 'RU'),
            Locale('tr', 'TR'),
            Locale('zh', 'CN')
          ],
          home: const SplashScreen());
    });
  }
}
