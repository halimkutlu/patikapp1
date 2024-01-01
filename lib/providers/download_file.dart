import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dbprovider.dart';

Future<void> downloadFile(String url, {required String filename}) async {
  final httpClient = http.Client();

  try {
    bool permissionStatus;
    final deviceInfo = await DeviceInfoPlugin().androidInfo;

    // Android versiyon kontrolü
    if (deviceInfo.version.sdkInt > 32) {
      permissionStatus =
          await Permission.manageExternalStorage.request().isGranted;
    } else {
      permissionStatus =
          await Permission.manageExternalStorage.request().isGranted;
    }

    if (!permissionStatus) {
      throw Exception('External storage permission not granted');
    }

    final appDocDir = await getApplicationCacheDirectory();

    // // "PatikApp" klasörünü oluştur
    // final patikAppDir = Directory('${appDocDir.path}/PatikApp');
    // if (!await patikAppDir.exists()) {
    //   await patikAppDir.create(recursive: true);
    // }

    final file = File('${appDocDir.path}/$filename.zip');

    // Dosya zaten var mı kontrol et
    if (await file.exists()) {
      print('File already exists: ${file.path}');
      return; // Dosya zaten varsa işlemi sonlandır
    }

    final Map<String, String> body = {
      "lcid": "0",
      "code": filename,
      "phoneID": "1293812938"
    };

    final request = http.Request('POST', Uri.parse(url));
    request.headers['Content-Type'] = "application/json";
    request.body = jsonEncode(body);
    request.headers["Authorization"] =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjEiLCJuYmYiOjE3MDQwMTk4MzcsImV4cCI6MTczNTU1NTgzNywiaWF0IjoxNzA0MDE5ODM3fQ.SPyrL4275szDfJxZaav1r9fXgH7dEt_7xlftat11qNk";

    // Dosyanın zaten var olup olmadığını API'den kontrol et
    final response = await httpClient.send(request);
    if (response.statusCode == 200) {
      final List<List<int>> chunks = [];

      await response.stream.forEach((List<int> chunk) {
        chunks.add(chunk);
      });

      final Uint8List bytes =
          Uint8List.fromList(chunks.expand((x) => x).toList());

      await file.writeAsBytes(bytes);

      print('File downloaded successfully: ${file.path}');
      // DbProvider dbProvider = DbProvider();
      // dbProvider.runProcess("tr-TR");
    } else {
      print('Request failed with status: ${response.statusCode}');
      // Handle error response here
    }
  } catch (e) {
    print('Error during file download: $e');
    // Handle network or other errors here
  } finally {
    httpClient.close();
  }
}
