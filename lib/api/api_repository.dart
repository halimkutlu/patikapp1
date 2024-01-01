// ignore_for_file: non_constant_identifier_names, unused_local_variable, avoid_print, depend_on_referenced_packages

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:leblebiapp/api/api_urls.dart';
import 'package:leblebiapp/api/static_variables.dart';
import 'package:leblebiapp/models/http_response.model.dart';
import 'package:leblebiapp/models/user.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class APIRepository {
  var dio = Dio();
  final String _baseUrl = BASE_URL;

//Servisten gelen cevap için bekleme süresi
//İleride değiştirilebilir.
  final int timeout = 120000;

//Uygulama içerisinde kullanılan token 30 dakika içerisinde yenileniyor, sayfa içerisinde gezen kulanıcı 30 dakika boyunca işlem yapmaz
//ise tekrar token alarak işlemlerine devam etmesi sağlanır.
//RefreshToken
  ReloadApiBase(String tokenValue) async {
    dio = Dio(BaseOptions(baseUrl: _baseUrl, headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=utf-8",
      "X-Requested-With": "XMLHttpRequest",
    }));
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient dioClient) {
      dioClient.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      return dioClient;
    };
    initializeInterceptors(tokenValue);
  }

  initializeInterceptors(String tokenValue) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, requestInterceptorHandler) {
        String token = tokenValue;
        if (token != "") {
          print("Token:$token");
          options.headers["Authorization"] =
              "Bearer $token"; //Sending token with every request accept login
          options.followRedirects = false;
          return requestInterceptorHandler.next(options);
        } else {
          // ignore: void_checks
          return requestInterceptorHandler.next(options);
        }
      },
      onResponse: (response, responseInterceptorHandler) {
        var map = Map<String, dynamic>.from(response.data);
        if (response.statusCode == 401) {
/*           _dio!.interceptors.requestLock.lock();
          _dio!.interceptors.responseLock.lock(); */
          print(response.statusCode);
        }
        print('onResponse:${response.statusCode}');
        // ${response.statusCode} ${response.data}');
        return responseInterceptorHandler.next(response);
      },
      onError: (error, errorInterceptorHandler) {
        if (error.response != null) {
          print("StatusCode:${error.response!.statusCode}");
        }
        print("Dio onError:${error.message}");
        return errorInterceptorHandler.next(error);
      },
    ));
  }

//Login Servis Sağlayıcısı
  Future<UserResult> login(
      {@required String? userName,
      @required String? password,
      @required bool? rememberMe}) async {
    try {
      var result = UserResult(message: "Başarili", success: true);

      await ReloadApiBase("");

      Future.delayed(const Duration(seconds: 2)).whenComplete(() {});
      //Kullanılacak servisin içeriğine göre içerik değiştirilebilir.
      final response = await dio.post(loginUrl, data: {
        "userName": userName,
        "password": password,
      });
      //Gelen response değerinin durumuna göre kontroller sağlanabilir.
      if (response.statusCode != 200) {
        result.message =
            response.statusMessage ?? response.statusMessage ?? "Giris Hatasi";

        return result;
      } else {
        result.data = User.fromJson(response.data);
        if (result.data != null) {
          ReloadApiBase(result.data!.token!);
          // String userString = json.encode(response);
          // print(userString);
          StaticVariables.Name = result.data!.firstName!;
          StaticVariables.Surname = result.data!.lastName!;
          StaticVariables.Roles = result.data!.roles!;
          StaticVariables.UserName = result.data!.username!;

          saveToken(userName!, password!, result.data!.token!);
          if (rememberMe != false) {
            rememberMeOption();
          }
          return UserResult(
            message: result.message,
            data: result.data,
            success: result.success,
          );
        }
      }
    } on DioError catch (e) {
      if (DioErrorType.badResponse == e.type) {
        if (e.response!.statusCode == 401) {
          return UserResult(success: false, message: "Yetkisiz Erişim");
        }
        return UserResult(success: false, message: "İstek hatası");
      }

      if (DioErrorType.connectionTimeout == e.type) {
        return UserResult(success: false, message: "Zaman Aşımı");
      }
      if (DioErrorType.sendTimeout == e.type) {
        return UserResult(success: false, message: "Zaman Aşımı");
      }
      if (DioErrorType.cancel == e.type) {
        return UserResult(success: false, message: "Bağlantı Hatası");
      }
      if (e.response != null) {
      } else {
        return UserResult(success: false, message: "Yetkisiz Erişim");
      }
    }
    return UserResult(success: false, message: "Yetkisiz Erişim");
  }

//sayfalama get metodu
//Verilen Sayfalama şeklinde çekilmesini sağlayan servis bağlantısı
  Future<httpSonucModel> getListForPaging(
      {@required String? controller,
      @required Map<String, dynamic>? queryParameters,
      bool redirectLogin = false}) async {
    try {
      ReloadApiBase(StaticVariables.token);
      final response =
          await dio.get(controller!, queryParameters: queryParameters);
      if (response != null) {
        return httpSonucModel(
          data: response,
          success: true,
          message: 'Başarılı',
        );
      }
      return httpSonucModel(
        data: response,
        success: false,
        message: 'Hata',
      );
    } on DioError catch (e) {
      if (DioErrorType.unknown == e.type) {
        return httpSonucModel(
          data: {},
          success: false,
          message: "Bağlantı Hatası",
        );
      }
      if (DioErrorType.badResponse == e.type) {
        if (e.response!.statusCode == 401) {
          return httpSonucModel(
            success: false,
            message: "Yetkisiz Erişim",
            data: {},
          );
        }
        return httpSonucModel(
          data: {},
          success: false,
          message: "İstek hatası",
        );
      }
      if (DioErrorType.connectionTimeout == e.type) {
        return httpSonucModel(
          data: {},
          success: false,
          message: "Sistem zaman aşımına uğradı",
        );
      }
      if (DioErrorType.sendTimeout == e.type) {
        return httpSonucModel(
          data: {},
          success: false,
          message: "Sistem zaman aşımına uğradı",
        );
      }
      if (e.response != null) {
        return httpSonucModel(
          data: {},
          success: false,
          message: 'Hata',
        );
      } else {
        //Hata dönüşü
        return httpSonucModel(
          data: {},
          success: false,
          message: e.message,
        );
      }
    }
  }

  Future<httpSonucModel> post(
      {@required String? controller,
      @required dynamic data,
      bool redirectLogin = false}) async {
    try {
      ReloadApiBase(StaticVariables.token);
      final response = await dio.post(controller!, data: data);
      httpSonucModel result = httpSonucModel.fromJsonData(response.data);

      return result;
    } on DioError catch (e) {
      if (DioErrorType.unknown == e.type) {
        return httpSonucModel(
          success: false,
          message: "Bağlantı Hatası",
        );
      }
      if (DioErrorType.badResponse == e.type) {
        if (e.response!.statusCode == 401) {
          return httpSonucModel(
            success: false,
            message: "Yetkisiz Erişim",
          );
        }
        return httpSonucModel(
          success: false,
          message: "İstek hatası",
        );
      }
      if (DioErrorType.connectionTimeout == e.type) {
        return httpSonucModel(
          success: false,
          message: "Sistem zaman aşımına uğradı",
        );
      }
      if (DioErrorType.sendTimeout == e.type) {
        return httpSonucModel(
          success: false,
          message: "Sistem zaman aşımına uğradı",
        );
      }
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        // Error due to setting up or sending the request
        print('Error sending request!');
        print(e.message);
        return httpSonucModel(
          success: false,
          message: e.message,
        );
      }
      return httpSonucModel(
        success: false,
        message: e.message,
      );
    }
  }

//get metodu
//Verilen çekilmesini sağlayan servis bağlantısı
  Future<httpSonucModel> get(
      {@required String? controller,
      Map<String, dynamic>? queryParameters,
      bool redirectLogin = false}) async {
    var result = httpSonucModel(
      data: {},
      success: true,
      message: "Başarılı",
    );
    try {
      ReloadApiBase(StaticVariables.token);
      final response =
          await dio.get(controller!, queryParameters: queryParameters);
      if (response != null) {
        return httpSonucModel(
          data: response,
          success: true,
          message: "Başarılı",
        );
      }
      return httpSonucModel(
        data: response,
        success: false,
        message: "Başarısız",
      );
    } on DioError catch (e) {
      if (DioErrorType.unknown == e.type) {
        return httpSonucModel(
          data: {},
          success: false,
          message: "Bağlantı Hatası",
        );
      }
      if (DioErrorType.badResponse == e.type) {
        if (e.response!.statusCode == 401) {
          return httpSonucModel(
            success: false,
            message: "Yetkisiz Erişim",
            data: {},
          );
        }
        return httpSonucModel(
          data: {},
          success: false,
          message: "İstek hatası",
        );
      }
      if (DioErrorType.connectionTimeout == e.type) {
        return httpSonucModel(
          data: {},
          success: false,
          message: "Sistem zaman aşımına uğradı",
        );
      }
      if (DioErrorType.sendTimeout == e.type) {
        return httpSonucModel(
          data: {},
          success: false,
          message: "Sistem zaman aşımına uğradı",
        );
      }
      if (e.response != null) {
        return httpSonucModel(
          data: {},
          success: false,
          message: e.message,
        );
      } else {
        return httpSonucModel(
          data: {},
          success: false,
          message: e.message,
        );
      }
    }
  }

//Beni hatırla butonuna basıldığı takdirde calısan alan,
//Kullanıcının bilgilerini localstorage üzerine kayıt edilir ve bir dahaki girişinde direkt olarak local storage üzerinden alınır.
  void rememberMeOption() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setString("Token", StaticVariables.token);
    // await prefs.setString("cryptedUserName", StaticVariables.cryptedUserName);
    // await prefs.setString("cryptedPassword", StaticVariables.cryptedPassword);
  }

//Kullanıcı giriş yaptıktan sonra gelen tokenı local storage üzerinde kayıt edilmesini sağlayan alan
  void saveToken(String username, String password, String token) {
    //Uygulama güvenliği için gelen kullanıcı kayıtları hashed edilir.

    // var stringBytesSifre = utf8.encode(password);
    // var stringBytesKadi = utf8.encode(username);
    // var gzipBytesSifre = GZipEncoder().encode(stringBytesSifre);
    // var gzipBytesKadi = GZipEncoder().encode(stringBytesKadi);
    // var stringEncodedSifre = base64.encode(gzipBytesSifre!);
    // var stringEncodedKadi = base64.encode(gzipBytesKadi!);

    // StaticVariables.cryptedPassword = stringEncodedSifre;
    // StaticVariables.cryptedUserName = stringEncodedKadi;
    StaticVariables.token = token;
  }

//Şifreler hashed olarak tutulması gerektiği için encode ediliyor.
  encode(String zipText) {
    // var stringBytes = utf8.encode(zipText);
    // var gzipBytes = GZipEncoder().encode(stringBytes);
    // var stringEncoded = base64.encode(gzipBytes!);
    // debugPrint('encoded: $stringEncoded');
  }

//------------------------- ALTERNATİF KULLANIM-------------------------------------------------------------

  //Verilen gönderilmesini ve dönüş olarak İstenilen model için dönmesini sağlayan sağlayan servis bağlantısı
}
