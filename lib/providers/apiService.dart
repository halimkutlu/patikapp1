import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:patikmobile/api/api_urls.dart';
import 'package:patikmobile/api/static_variables.dart';
import 'package:patikmobile/models/http_response.model.dart';
import 'package:patikmobile/models/user.dart';
import 'package:patikmobile/models/user.model.dart';
import 'package:patikmobile/providers/deviceProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;
  static Map<String, String> headers = {
    "Accept": "application/json",
    "content-type": "application/json; charset=utf-8",
    "X-Requested-With": "XMLHttpRequest"
  };

  ApiService({required this.baseUrl});

  // Statik initialize yöntemi
  static Future<void> initialize() async {
    headers['PhoneID'] = GetDeviceProvider.getPhoneId();
    var token = await GetToken();
    headers['Authorization'] = token;
  }

  // GET request
  Future<httpSonucModel> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return httpSonucModel.fromJsonData(json.decode(response.body));
    } else {
      return httpSonucModel.fromJsonData(json.decode(response.body));
    }
  }

  // POST request
  Future<httpSonucModel> post(
      String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return httpSonucModel.fromJsonData(json.decode(response.body));
    } else {
      return httpSonucModel.fromJsonData(json.decode(response.body));
    }
  }
}

// Statik değişkenler örneği
// ignore: non_constant_identifier_names
Future<String> GetToken() async {
  var token = StaticVariables.token;
  return token;
}

// DeviceProvider örneği
class GetDeviceProvider {
  static String getPhoneId() {
    return DeviceProvider.getPhoneId();
  }
}
