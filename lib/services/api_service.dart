import 'dart:convert';
import 'dart:io';

import 'package:flutter_core_module/enums.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_core_module/services/logger_service.dart';
import 'package:flutter_core_module/services/preference_service.dart';

//5%=FVb7L%#c+f+J

class ApiService {
  factory ApiService() => _instance;
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  int timeOut = 60;
  String authKey='';
  bool showReleaseLog=false;
  void setTimeOut({required int durationInSeconds}) {
    timeOut = durationInSeconds <= 0 ? 60 : durationInSeconds;
  }

  void setAuthorizationPreferenceKey({required String authSharedPreferenceKey}) {
    authKey =authSharedPreferenceKey;
  }

  Map<String,String> _getHeader({bool isFormData=false}){
    return {
      if(isFormData==false)
      'Content-Type':'application/json',
      'Authorization':PreferenceService().getString(defaultValue: '',key: authKey)
    };


  }
  Future<Map<String, dynamic>> get({
    required String url,
    required Map<String, String> headers,
  }) async {
    Map<String, dynamic> apiResponse = {};
    try {
      final response = await http
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
      if(response.statusCode!=200){
        LoggerService().log(message: 'API status code warning',level: LogLevel.warning);
      }
      apiResponse = json.decode(response.body);
      apiResponse.addAll({'httpStatusCode': response.statusCode});
    } catch (e) {
      apiResponse.addAll({'httpStatusCode': -1, 'error': e.toString()});
      LoggerService().log(message: e,level: LogLevel.error);
    }
    return apiResponse;
  }

  Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, String> headers,
    required Map<String, dynamic> requestBody,
  }) async {
    Map<String, dynamic> apiResponse = {};
    try {
      bool hasFile = requestBody.values.any((v) => v is http.MultipartFile|| v is File);
      LoggerService().log(message: 'request url===>$url\nRequest body===>${json.encode(requestBody)}');
      final response = await http
          .post(
            Uri.parse(url),
            headers: _getHeader(isFormData: hasFile),
            body:hasFile ?  requestBody:  json.encode(requestBody),
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
      if(response.statusCode!=200){
        LoggerService().log(message: 'API status code warning',level: LogLevel.warning);
      }
      apiResponse = json.decode(response.body);
      apiResponse.addAll({'httpStatusCode': response.statusCode});
    } catch (e) {
      apiResponse.addAll({'httpStatusCode': -1, 'error': e.toString()});
      LoggerService().log(message: e,level: LogLevel.error);
    }
    return apiResponse;
  }

  Future<Map<String, dynamic>> put({
    required String url,
    required Map<String, String> headers,
    required Map<String, dynamic> requestBody,
  }) async {

    Map<String, dynamic> apiResponse = {};
    try {
      bool hasFile = requestBody.values.any((v) => v is http.MultipartFile|| v is File);
      final response = await http
          .put(Uri.parse(url), headers: _getHeader(isFormData: hasFile), body: hasFile ?  requestBody:  json.encode(requestBody))
          .timeout(
            Duration(seconds: timeOut),
            onTimeout: () {
              return http.Response(
                json.encode({'error': 'Request timed out'}),
                408,
              );
            },
          );
      if(response.statusCode!=200){
        LoggerService().log(message: 'API status code warning',level: LogLevel.warning);
      }
      apiResponse = json.decode(response.body);
      apiResponse.addAll({'httpStatusCode': response.statusCode});
    } catch (e) {
      apiResponse.addAll({'httpStatusCode': -1, 'error': e.toString()});
      LoggerService().log(message: e,level: LogLevel.error);
    }
    return apiResponse;
  }

  Future<Map<String, dynamic>> delete({
    required String url,
    required Map<String, String> headers,
    required Map<String, dynamic> requestBody,
  }) async {
    Map<String, dynamic> apiResponse = {};
    try {
      bool hasFile = requestBody.values.any((v) => v is http.MultipartFile|| v is File);
      final response = await http
          .delete(
            Uri.parse(url),
            headers: _getHeader(isFormData: hasFile),
            body: hasFile ?  requestBody:  json.encode(requestBody),
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
      if(response.statusCode!=200){
        LoggerService().log(message: 'API status code warning',level: LogLevel.warning);
      }
      apiResponse = json.decode(response.body);
      apiResponse.addAll({'httpStatusCode': response.statusCode});
    } catch (e) {
      apiResponse.addAll({'httpStatusCode': -1, 'error': e.toString()});
      LoggerService().log(message: e,level: LogLevel.error);
    }
    return apiResponse;
  }
}
