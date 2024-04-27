// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/providers/deviceProvider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_urls.dart';
import '../models/language.model.dart';

Future<bool> getPermissions() async {
  bool gotPermissions = false;

  if (Platform.isAndroid) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    var sdkInt = androidInfo.version.sdkInt; // SDK, example: 31

    if (sdkInt >= 30) {
      gotPermissions =
          await Permission.manageExternalStorage.request().isGranted;
    } else {
      // (SDK < 30)
      var storage = await Permission.storage.status;

      if (storage != PermissionStatus.granted) {
        await Permission.storage.request();
      }

      storage = await Permission.storage.status;

      if (storage == PermissionStatus.granted) {
        gotPermissions = true;
      }
    }
  } else {
    gotPermissions = true;
  }

  return gotPermissions;
}

Future<FileDownloadStatus> downloadFile(String endpoint, BuildContext context,
    {required int lcid, void Function(int, int)? onReceiveProgress}) async {
  FileDownloadStatus result = FileDownloadStatus();
  result.status = false;

  String url = "$BASE_URL/Downloads/$endpoint";
  String filename = Languages.GetCodeFromLCID(lcid);
  try {
    bool permissionStatus = await getPermissions();

    if (!permissionStatus) {
      result.status = false;
      result.message = AppLocalizations.of(context).translate("178");
      return result;
    }

    final appDocDir = await getApplicationCacheDirectory();
    final file = File('${appDocDir.path}/$filename.zip');

    if (await file.exists()) {
      await file.delete();
    }

    final Map<String, Object> body = {"lcid": lcid, "code": filename};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("Token");
    Map<String, Object> header = {
      "PhoneID": DeviceProvider.getPhoneId(),
      "Authorization": token ?? "",
      "Content-Type": "application/json"
    };

    Response response = await Dio().download(url, file.path,
        data: body,
        onReceiveProgress: onReceiveProgress,
        options: Options(
            method: "POST",
            contentType: "application/Json",
            headers: header,
            responseType: ResponseType.bytes));
    print('Request failed with status: ${response.statusCode}');
    result.status = response.statusCode == 200 && await file.exists();
    if (!result.status) {
      result.message = AppLocalizations.of(context).translate("177");
    }
  } catch (e) {
    result.status = false;
    result.message = AppLocalizations.of(context).translate("177");
    print('Error during file download: $e');
  } finally {
    // ignore: control_flow_in_finally
    return result;
  }
}
