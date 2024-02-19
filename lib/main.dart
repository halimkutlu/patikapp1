// ignore_for_file: unused_local_variable, prefer_const_constructors

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localization_delegate.dart';
import 'package:patikmobile/pages/select_dialog_category.dart';
import 'package:patikmobile/pages/splashScreen.dart';
import 'package:patikmobile/providers/boxPageProvider.dart';
import 'package:patikmobile/providers/categoriesProvider.dart';
import 'package:patikmobile/providers/changePasswordProvider.dart';
import 'package:patikmobile/providers/dbprovider.dart';
import 'package:patikmobile/providers/deviceProvider.dart';
import 'package:patikmobile/providers/dialogCategoriesProvider.dart';
import 'package:patikmobile/providers/games_providers/fill_the_blank_game.dart';
import 'package:patikmobile/providers/games_providers/match_moving_square_game_provider.dart';
import 'package:patikmobile/providers/games_providers/match_with_picture_game_provider.dart';
import 'package:patikmobile/providers/games_providers/match_with_sound_game_provider.dart';
import 'package:patikmobile/providers/games_providers/multiple_choice_game_provider.dart';
import 'package:patikmobile/providers/games_providers/swipe_card_game_provider.dart';
import 'package:patikmobile/providers/introductionPageProvider.dart';
import 'package:patikmobile/providers/loginProvider.dart';
import 'package:patikmobile/providers/mainPageProvider.dart';
import 'package:patikmobile/providers/dashboardProvider.dart';
import 'package:patikmobile/providers/registerProvider.dart';
import 'package:patikmobile/providers/splashScreenProvider.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:patikmobile/providers/trainingProvider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sizer/sizer.dart';

//indirilen dilin kayıt edilmesi (tekrar uygulama açıldığında o dilden devam edicek)
//progress indicator

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initGoogleMobileAds();
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

Future<InitializationStatus> _initGoogleMobileAds() {
  // TODO: Initialize Google Mobile Ads SDK
  return MobileAds.instance.initialize();
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
  ChangeNotifierProvider<CategoriesProvider>(
      create: (_) => CategoriesProvider()),
  ChangeNotifierProvider<TrainingProvider>(create: (_) => TrainingProvider()),
  ChangeNotifierProvider<SwipeCardGameProvider>(
    create: (_) => SwipeCardGameProvider(),
  ),
  ChangeNotifierProvider<BoxPageProvider>(create: (_) => BoxPageProvider()),
  ChangeNotifierProvider<MatchWithPictureGameProvide>(
      create: (_) => MatchWithPictureGameProvide()),
  ChangeNotifierProvider<MatchWithSoundGameProvide>(
      create: (_) => MatchWithSoundGameProvide()),
  ChangeNotifierProvider<FillTheBlankGameProvider>(
      create: (_) => FillTheBlankGameProvider()),
  ChangeNotifierProvider<AppDbProvider>(create: (_) => AppDbProvider()),
  ChangeNotifierProvider<MultipleChoiceGameProvider>(
      create: (_) => MultipleChoiceGameProvider()),
  ChangeNotifierProvider<MovingSquaresGameProvide>(
      create: (_) => MovingSquaresGameProvide()),
  ChangeNotifierProvider<DialogCategoriesProvider>(
      create: (_) => DialogCategoriesProvider()),
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

  @override
  Widget build(BuildContext context) {
    DeviceProvider.Init(context);
    TextEditingController textController = TextEditingController();
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
          home: const SplashScreen()
          // home: Column(
          //   children: [
          //     Text(textController.text,
          //         style: TextStyle(
          //             color: Colors.white,
          //             fontSize: 20,
          //             fontWeight: FontWeight.bold)),
          //     NumericKeypad(
          //       controller: textController,
          //       word: "YediğinHurmalar",
          //     )
          //   ],
          // )

          );
    });
  }
}
