// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:patikmobile/locale/ChangeLanguage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_urls.dart';
import '../models/language.model.dart';

Future<FileDownloadStatus> downloadFile(String endpoint,
    {required int lcid}) async {
  FileDownloadStatus result = FileDownloadStatus();
  result.status = false;

  final httpClient = http.Client();
  String url = "$BASE_URL/Downloads/$endpoint";
  String filename = Languages.GetCodeFromLCID(lcid);
  try {
    final deviceId = await getPhoneId();
    bool permissionStatus =
        await Permission.manageExternalStorage.request().isGranted;

    if (!permissionStatus) {
      result.status = false;
      result.message =
          "Dosyanın indirilebilmesi için saklama izni verilmesi gerekmektedir";
      return result;
    }

    final appDocDir = await getApplicationCacheDirectory();

    final file = File('${appDocDir.path}/$filename.zip');

    if (await file.exists()) {
      //version kontrolü yapılabilir.
      result.status = true;
      result.message = "Bu dil daha önce indirilmiş";
      print('File already exists: ${file.path}');
      return result;
    }

    final Map<String, String> body = {
      "lcid": "0",
      "code": filename,
      "phoneID": deviceId
    };

    final request = http.Request('POST', Uri.parse(url));
    request.headers['Content-Type'] = "application/json";
    request.body = jsonEncode(body);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("Token");
    request.headers["Authorization"] = token ?? "";

    // Dosyanın zaten var olup olmadığını API'den kontrol et
    final response = await httpClient.send(request);
    if (response.statusCode == 200) {
      final List<List<int>> chunks = [];

      await response.stream.forEach((List<int> chunk) {
        //loading indicator konulacak subscribe ile dinleyen metod yazılıcak
        chunks.add(chunk);
      });

      final Uint8List bytes =
          Uint8List.fromList(chunks.expand((x) => x).toList());

      await file.writeAsBytes(bytes);

      print('File downloaded successfully: ${file.path}');
      result.status = true;
      result.message = "Dosya başarılı bir şekilde indirildi";
    } else {
      result.status = false;
      result.message = "Dosya indirilirken bir hata oluştu";

      print('Request failed with status: ${response.statusCode}');
    }
    return result;
  } catch (e) {
    result.status = false;
    result.message = "Dosya indirilirken bir hata oluştu";
    print('Error during file download: $e');
  } finally {
    httpClient.close();
    return result;
  }
}
