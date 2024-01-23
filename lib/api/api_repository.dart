// ignore_for_file: non_constant_identifier_names, unused_local_variable, avoid_print, depend_on_referenced_packages, deprecated_member_use

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:patikmobile/api/api_urls.dart';
import 'package:patikmobile/api/static_variables.dart';
import 'package:patikmobile/models/http_response.model.dart';
import 'package:patikmobile/models/user.model.dart';
import 'package:patikmobile/providers/deviceProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class APIRepository {
  var dio = Dio();
  final String _baseUrl = BASE_URL;
//Servisten gelen cevap için bekleme süresi
//İleride değiştirilebilir.
  final int timeout = 120000;

  APIRepository() {
    dio = Dio(BaseOptions(baseUrl: _baseUrl, followRedirects: true, headers: {
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

    initializeInterceptors();
  }
//Uygulama içerisinde kullanılan token 30 dakika içerisinde yenileniyor, sayfa içerisinde gezen kulanıcı 30 dakika boyunca işlem yapmaz
//ise tekrar token alarak işlemlerine devam etmesi sağlanır.
//RefreshToken

  initializeInterceptors() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, requestInterceptorHandler) {
        StaticVariables.loading = true;
        //_startLoadingCallback!();
        options.headers['PhoneID'] = DeviceProvider.getPhoneId();

        if (StaticVariables.token != "") {
          print("Token:${StaticVariables.token}");
          options.headers["Authorization"] = StaticVariables.token;
          options.followRedirects = false;
          return requestInterceptorHandler.next(options);
        } else {
          return requestInterceptorHandler.next(options);
        }
      },
      onResponse: (response, responseInterceptorHandler) {
        StaticVariables.loading = false;
        var map = Map<String, dynamic>.from(response.data);
        if (response.statusCode == 401) {
          print(response.statusCode);
        }
        print('onResponse:${response.statusCode}');
        return responseInterceptorHandler.next(response);
      },
      onError: (error, errorInterceptorHandler) {
        StaticVariables.loading = false;
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
      @required bool? rememberMe,
      String? Uid,
      String? Name}) async {
    try {
      var result = UserResult(message: "Başarili", success: true);
      Future.delayed(const Duration(seconds: 2)).whenComplete(() {});
      //Kullanılacak servisin içeriğine göre içerik değiştirilebilir.
      print("login olunuyor.");
      print("$userName $password $Uid $Name");
      final response = await dio.post(loginUrl, data: {
        "userName": userName,
        "password": password,
        "Uid": Uid,
        "Name": Name
      });
      //Gelen response değerinin durumuna göre kontroller sağlanabilir.
      print("login cevap geldi");

      if (response.statusCode != 200) {
        print("login cevap geldi: hata");

        result.message =
            response.statusMessage ?? response.statusMessage ?? "Giris Hatasi";

        return result;
      } else {
        if (response.data!['Token'] != null) {
          result.data = User.fromJson(response.data);
          if (result.data != null) {
            StaticVariables.token = result.data!.token!;
            StaticVariables.Name = result.data!.firstName ?? "";
            StaticVariables.Surname = result.data!.lastName ?? "";
            StaticVariables.Roles = result.data!.roles!;
            StaticVariables.UserName = result.data!.username!;
            saveToken(
                password!,
                result.data!.token!,
                result.data!.firstName!,
                result.data!.lastName!,
                result.data!.roles!,
                result.data!.username!);
            if (rememberMe != false) {
              rememberMeOption();
            }
            return UserResult(
              message: result.message,
              data: result.data,
              success: result.success,
            );
          }
        } else {
          return UserResult(
              message: response.data['Message'],
              success: response.data['Success']);
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
      //ReloadApiBase(StaticVariables.token);
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
          message: e.response?.data["errors"]
                  ?.toString()
                  .replaceAll("{", "")
                  .replaceAll("}", "")
                  .replaceAll("[", "")
                  .replaceAll("]", "") ??
              "İstek hatası",
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
      //ReloadApiBase(StaticVariables.token);
      final response =
          await dio.get(controller!, queryParameters: queryParameters);
      if (response != null) {
        return httpSonucModel(
          data: response.data['Data'],
          success: response.data['Success'],
          message: response.data['Message'],
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

  void saveToken(String password, String token, String firstName,
      String lastName, List<int> roles, String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("Token", token);
    await prefs.setString("firstName", firstName);
    await prefs.setString("lastName", lastName);
    await prefs.setString("userName", username);
    await prefs.setString("roles", roles.toString()); //değiştirilicek

    StaticVariables.token = token;
  }

  void removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("Token");
    await prefs.remove("firstName");
    await prefs.remove("lastName");
    await prefs.remove("userName");
    await prefs.remove("roles"); //değiştirilicek

    StaticVariables.reset();
  }

//Şifreler hashed olarak tutulması gerektiği için encode ediliyor.
  encode(String zipText) {
    // var stringBytes = utf8.encode(zipText);
    // var gzipBytes = GZipEncoder().encode(stringBytes);
    // var stringEncoded = base64.encode(gzipBytes!);
    // debugPrint('encoded: $stringEncoded');
  }

  // getFirstTimeLogin() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var firstTimeLogin = prefs.getBool("firstTimeLogin");
  //   if (firstTimeLogin == null) {
  //     prefs.setBool("firstTimeLogin", true);
  //     firstTimeLogin = true;
  //   }
  //   StaticVariables.FirstTimeLogin = firstTimeLogin;
  //   return firstTimeLogin;
  // }

  // setFirstTimeLogin() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setBool("firstTimeLogin", false);
  //   StaticVariables.FirstTimeLogin = false;
  // }
}
