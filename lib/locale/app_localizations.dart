import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patikmobile/models/language.model.dart';

class AppLocalizations {
  // The locale for which the app is localized
  final Lcid locale;
  // Map to hold the localized strings
  Map<String, String> _localizedStrings = {};

  // Constructor
  AppLocalizations(this.locale);

  // Method to get the current instance of AppLocalizations
  static AppLocalizations of(BuildContext context) {
    // Try to get the localization for the current context, if not available, default to English
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(Languages.GetLngFromCode("en-US"));
  }

  // Method to load the localized strings
  Future<bool> load({String? lng}) async {
    lng ??= locale.Code;
    // Load the localization file from the assets
    String jsonString =
        await rootBundle.loadString('lib/assets/locales/$lng.json');
    // Decode the JSON
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    // Convert the dynamic values to String and store them in the _localizedStrings map
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    // Return true when loading is done
    return true;
  }

  // Method to get a localized string
  String translate(String key) {
    // Return the localized string if it exists, otherwise return a default message
    return _localizedStrings[key] ?? 'Key not found';
  }
}
