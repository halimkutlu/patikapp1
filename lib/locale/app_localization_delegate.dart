import 'dart:io';

import 'package:flutter/material.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/models/language.model.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Class for handling localization delegate
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  // Constructor
  const AppLocalizationsDelegate();

  // Method to check if a locale is supported
  @override
  bool isSupported(Locale locale) {
    // Currently only English and Spanish are supported
    return const [
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
    ].contains(locale);
  }

  // Method to load the localized strings for a locale
  @override
  Future<AppLocalizations> load(Locale locale) async {
    if (StorageProvider.appLanguge == null) {
      var phoneLng = Platform.localeName.split("_");
      locale = Locale(phoneLng[0], phoneLng[1]);
      if (!isSupported(locale)) {
        locale = const Locale("en");
      }
      SharedPreferences shrdp = await SharedPreferences.getInstance();
      int llcid = shrdp.getInt(StorageProvider.appLcidKey) ??
          Languages.GetLCIDFromCode(
              "${locale.languageCode}-${locale.countryCode}"); // default en-US
      StorageProvider.appLanguge = Languages.GetLngFromLCID(llcid);
    }

    AppLocalizations localizations =
        AppLocalizations(StorageProvider.appLanguge!);
    // Load the localized strings and return the AppLocalizations instance
    return localizations.load().then((bool _) {
      return localizations;
    });
  }

  // Method to decide if the delegate should be reloaded
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
