// // ignore_for_file: depend_on_referenced_packages, file_names

// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:patikmobile/locale/ChangeLanguage.dart';

// Duration _defaultConnectTimeout = const Duration(milliseconds: 120000);
// Duration _defaultReceiveTimeout = const Duration(milliseconds: 120000);

// class DioClient {
//   static DioClient? dioClient;
//   final String baseUrl;
//   Dio? _dio;
//   final String? tokenValue;
//   final List<Interceptor>? interceptors;
//   final String _formatError = "Geçersiz veri türü";

//   DioClient(
//     this.baseUrl,
//     Dio dio,
//     this.tokenValue, {
//     this.interceptors,
//   }) {
//     _dio = dio;

//     _dio!
//       ..options.baseUrl = baseUrl
//       ..options.connectTimeout = _defaultConnectTimeout
//       ..options.receiveTimeout = _defaultReceiveTimeout
//       ..options.sendTimeout = _defaultConnectTimeout
//       ..httpClientAdapter
//       ..options.headers = {'Content-Type': 'application/json; charset=UTF-8'};

//     dio.options.headers['PhoneID'] = getPhoneId();
//     if (tokenValue!.isNotEmpty) {
//       dio.options.headers['Authorization'] = tokenValue;
//     }
//     if (interceptors?.isNotEmpty ?? false) {
//       _dio!.interceptors.addAll(interceptors!);
//     }

//     if (kDebugMode) {
//       _dio!.interceptors.add(LogInterceptor(
//           responseBody: true,
//           error: true,
//           requestHeader: false,
//           responseHeader: false,
//           request: false,
//           requestBody: false));
//     }
//   }

//   Future<dynamic> get(
//     String uri, {
//     Map<String, dynamic>? queryParameters,
//     Options? options,
//     CancelToken? cancelToken,
//     ProgressCallback? onReceiveProgress,
//   }) async {
//     try {
//       var response = await _dio!.get(
//         uri,
//         queryParameters: queryParameters,
//         cancelToken: cancelToken,
//         onReceiveProgress: onReceiveProgress,
//       );
//       return response.data;
//     } on SocketException catch (e) {
//       throw SocketException(e.toString());
//     } on FormatException catch (_) {
//       throw FormatException(_formatError);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<dynamic> post(
//     String uri, {
//     data,
//     Map<String, dynamic>? queryParameters,
//     CancelToken? cancelToken,
//     ProgressCallback? onSendProgress,
//     ProgressCallback? onReceiveProgress,
//   }) async {
//     try {
//       var response = await _dio!.post(
//         uri,
//         data: data,
//         queryParameters: queryParameters,
//         cancelToken: cancelToken,
//         onSendProgress: onSendProgress,
//         onReceiveProgress: onReceiveProgress,
//       );
//       return response.data;
//     } on FormatException catch (_) {
//       throw FormatException(_formatError);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<dynamic> patch(
//     String uri, {
//     data,
//     Map<String, dynamic>? queryParameters,
//     Options? options,
//     CancelToken? cancelToken,
//     ProgressCallback? onSendProgress,
//     ProgressCallback? onReceiveProgress,
//   }) async {
//     try {
//       var response = await _dio!.patch(
//         uri,
//         data: data,
//         queryParameters: queryParameters,
//         options: options,
//         cancelToken: cancelToken,
//         onSendProgress: onSendProgress,
//         onReceiveProgress: onReceiveProgress,
//       );
//       return response.data;
//     } on FormatException catch (_) {
//       throw FormatException(_formatError);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<dynamic> delete(
//     String uri, {
//     data,
//     Map<String, dynamic>? queryParameters,
//     Options? options,
//     CancelToken? cancelToken,
//   }) async {
//     try {
//       var response = await _dio!.delete(
//         uri,
//         data: data,
//         queryParameters: queryParameters,
//         options: options,
//         cancelToken: cancelToken,
//       );
//       return response.data;
//     } on FormatException catch (_) {
//       throw FormatException(_formatError);
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
