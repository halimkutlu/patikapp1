// ignore_for_file: unused_local_variable, prefer_const_constructors

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localization_delegate.dart';
import 'package:patikmobile/models/language.model.dart';
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
import 'package:patikmobile/services/ad_helper.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

//indirilen dilin kayıt edilmesi (tekrar uygulama açıldığında o dilden devam edicek)
//progress indicator

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initGoogleMobileAds();
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCIxSGHTmGLmrOy7xYLzSSY4j1MujNR1XA',
        appId: '1:799969018625:android:3cd8551608a3b49e6cd100',
        messagingSenderId: '799969018625',
        projectId: 'patik-2bd8d',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  SharedPreferences shrdp = await SharedPreferences.getInstance();

  var applcid = shrdp.getInt(StorageProvider.appLcidKey);
  Lcid locale = Languages.GetLngFromLCID(applcid ?? 1033);
  AppLocalizationsDelegate().load(const Locale('en'));
  runApp(MultiProvider(providers: providers, child: Phoenix(child: MyApp())));
}

Future<InitializationStatus> _initGoogleMobileAds() {
  return MobileAds.instance.initialize();
}

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<SplashScreenProvider>(
      create: (_) => SplashScreenProvider()),
  ChangeNotifierProvider<IntroductionPageProvider>(
      create: (_) => IntroductionPageProvider()),
  ChangeNotifierProvider<LoginProvider>(create: (_) => LoginProvider()),
  ChangeNotifierProvider<RegisterProvider>(create: (_) => RegisterProvider()),
  ChangeNotifierProvider<LearnDbProvider>(create: (_) => LearnDbProvider()),
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
  ChangeNotifierProvider<AdProvider>(create: (_) => AdProvider()),
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
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
          title: 'Multilingual Patik',
          theme: ThemeData(
              scaffoldBackgroundColor: MainColors.backgroundColor,
              primarySwatch: Colors.blue),
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
