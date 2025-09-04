import 'dart:convert';
import 'dart:io';
import 'package:flutter_core_module/enums.dart';
import 'package:flutter_core_module/services/connectivity_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_core_module/services/logger_service.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:http_interceptor/models/interceptor_contract.dart';

//5%=FVb7L%#c+f+J
class ApiService {
  factory ApiService() => _instance;
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  int timeOut = 60;
  String authKey = '';
  bool showReleaseLog = false;
  InterceptorContract? _interceptor;
  void setInterceptors({required InterceptorContract interceptor}) {
    _interceptor = interceptor;
  }
  InterceptedClient? get client {
    if (_interceptor != null) {
      return InterceptedClient.build(interceptors: [_interceptor!]);
    }
    return null;
  }
  Future<Map<String, dynamic>> get({
    required String url,
    Map<String, String> headers=const {},
  }) async {
    Map<String, dynamic> apiResponse = {};
    try {
      if(ConnectivityService().hasInternet==false){
        apiResponse.addAll({'httpStatusCode': -2, 'error': 'No Internet connection'});
      }else{
        final reqClient = client ?? http.Client();
        final response = await reqClient
            .get(Uri.parse(url), headers: headers)
            .timeout(
          Duration(seconds: timeOut),
          onTimeout: () {
            return http.Response(
              json.encode({'error': 'Request timed out'}),
              408,
            );
          },
        );
        if (response.statusCode != 200) {
          LoggerService().log(
            message: 'API status code warning',
            level: LogLevel.warning,
          );
        }
        apiResponse = json.decode(response.body);
        apiResponse.addAll({'httpStatusCode': response.statusCode});
      }
    } catch (e) {
      apiResponse.addAll({'httpStatusCode': -1, 'error': e.toString()});
      LoggerService().log(message: e, level: LogLevel.error);
    }
    return apiResponse;
  }

  Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, dynamic> requestBody, Map<String, String> headers=const{},
    bool isFormData=false
  }) async {
    Map<String, dynamic> apiResponse = {};
    try {

      if(ConnectivityService().hasInternet==false){
        apiResponse.addAll({'httpStatusCode': -2, 'error': 'No Internet connection'});
      }else {
        bool hasFile = requestBody.values.any(
              (v) => v is http.MultipartFile || v is File,
        );
        LoggerService().log(
          message:
          'request url===>$url\nRequest body===>${json.encode(requestBody)}',
        );

        late final http.Response response;
        if (hasFile || isFormData) {
          final reqClient = client ?? http.Client();
          var request = http.MultipartRequest('POST', Uri.parse(url));
          for (var entry in requestBody.entries) {
            var key = entry.key;
            var value = entry.value;

            if (value is http.MultipartFile) {
              request.files.add(value);
            } else if (value is File) {
              request.files.add(
                  await http.MultipartFile.fromPath(key, value.path));
            } else {
              request.fields[key] = '$value';
            }
          }

          await reqClient.send(request).then((resp) async {
            response = await http.Response.fromStream(resp);
          });
        } else {
          final reqClient = client ?? http.Client();
          response = await reqClient
              .post(
            Uri.parse(url),
            headers: _getHeader(isFormData: hasFile || isFormData),
            body: json.encode(requestBody),
          )
              .timeout(
            Duration(seconds: timeOut),
            onTimeout: () {
              return http.Response(
                json.encode({'error': 'Request timed out'}),
                408,
              );
            },
          );
        }

        if (response.statusCode != 200) {
          LoggerService().log(
            message: 'API status code warning',
            level: LogLevel.warning,
          );
        }
        apiResponse = json.decode(response.body);
        apiResponse.addAll({'httpStatusCode': response.statusCode});
      }
    } catch (e) {
      apiResponse.addAll({'httpStatusCode': -1, 'error': e.toString()});
      LoggerService().log(message: e, level: LogLevel.error);
    }
    return apiResponse;
  }

  Future<Map<String, dynamic>> put({
    required String url,
    required Map<String, dynamic> requestBody, Map<String, String> headers=const {},
    bool isFormData=false
  }) async {
    Map<String, dynamic> apiResponse = {};
    try {
      if(ConnectivityService().hasInternet==false){
        apiResponse.addAll({'httpStatusCode': -2, 'error': 'No Internet connection'});
      }else {
        bool hasFile = requestBody.values.any(
              (v) => v is http.MultipartFile || v is File,
        );

        late final http.Response response;
        if (hasFile || isFormData) {

          var request = http.MultipartRequest('PUT', Uri.parse(url));
          for (var entry in requestBody.entries) {
            var key = entry.key;
            var value = entry.value;

            if (value is http.MultipartFile) {
              request.files.add(value);
            } else if (value is File) {
              request.files.add(
                  await http.MultipartFile.fromPath(key, value.path));
            } else {
              request.fields[key] = '$value';
            }
          }
          final reqClient = client ?? http.Client();
          await reqClient.send(request).then((resp) async {
            response = await http.Response.fromStream(resp);
          });
        } else {
          final reqClient = client ?? http.Client();
          response = await reqClient
              .put(
            Uri.parse(url),
            headers: _getHeader(isFormData: hasFile || isFormData),
            body: json.encode(requestBody),
          )
              .timeout(
            Duration(seconds: timeOut),
            onTimeout: () {
              return http.Response(
                json.encode({'error': 'Request timed out'}),
                408,
              );
            },
          );
        }
        if (response.statusCode != 200) {
          LoggerService().log(
            message: 'API status code warning',
            level: LogLevel.warning,
          );
        }
        apiResponse = json.decode(response.body);
        apiResponse.addAll({'httpStatusCode': response.statusCode});
      }
    } catch (e) {
      apiResponse.addAll({'httpStatusCode': -1, 'error': e.toString()});
      LoggerService().log(message: e, level: LogLevel.error);
    }
    return apiResponse;
  }

  Future<Map<String, dynamic>> delete({
    required String url,
    required Map<String, String> headers,
    required Map<String, dynamic> requestBody,
    bool isFormData=false
  }) async {
    Map<String, dynamic> apiResponse = {};
    try {
      if(ConnectivityService().hasInternet==false){
        apiResponse.addAll({'httpStatusCode': -2, 'error': 'No Internet connection'});
      }else {
        bool hasFile = requestBody.values.any(
              (v) => v is http.MultipartFile || v is File,
        );
        late final http.Response response;
        if (hasFile || isFormData) {
          var request = http.MultipartRequest('DELETE', Uri.parse(url));
          for (var entry in requestBody.entries) {
            var key = entry.key;
            var value = entry.value;

            if (value is http.MultipartFile) {
              request.files.add(value);
            } else if (value is File) {
              request.files.add(
                  await http.MultipartFile.fromPath(key, value.path));
            } else {
              request.fields[key] = '$value';
            }
          }
          final reqClient = client ?? http.Client();

          await reqClient.send(request).then((resp) async {
            response = await http.Response.fromStream(resp);
          });
        } else {
          response = await http
              .delete(
            Uri.parse(url),
            headers: _getHeader(isFormData: hasFile || isFormData),
            body: json.encode(requestBody),
          )
              .timeout(
            Duration(seconds: timeOut),
            onTimeout: () {
              return http.Response(
                json.encode({'error': 'Request timed out'}),
                408,
              );
            },
          );
        }
        if (response.statusCode != 200) {
          LoggerService().log(
            message: 'API status code warning',
            level: LogLevel.warning,
          );
        }
        apiResponse = json.decode(response.body);
        apiResponse.addAll({'httpStatusCode': response.statusCode});
      }
    } catch (e) {
      apiResponse.addAll({'httpStatusCode': -1, 'error': e.toString()});
      LoggerService().log(message: e, level: LogLevel.error);
    }
    return apiResponse;
  }
  Future<bool> hasInternet() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 60));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
  void setTimeOut({required int durationInSeconds}) {
    timeOut = durationInSeconds <= 0 ? 60 : durationInSeconds;
  }

  Map<String, String> _getHeader({bool isFormData = false}) {
    return {
      if (isFormData == false) 'Content-Type': 'application/json',
    };
  }
}
