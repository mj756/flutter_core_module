import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class ApiService {
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  int timeoutInSeconds = 30;

  void setTimeOut({int seconds = 30}) {
    timeoutInSeconds = seconds;
  }

  Future<Map<String, dynamic>> get({
    required Uri url,
    Map<String, dynamic> requestBody = const {},
    Map<String, String> headers = const {},
  }) async {
    Map<String, dynamic> data = {};
    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(
            Duration(seconds: timeoutInSeconds),
            onTimeout: () =>
                http.Response('{"error":"Request timed out"}', 408),
          );
      data = json.decode(response.body);
      data.addAll({'httpStatusCode': response.statusCode});
    } catch (e) {
      data = {'httpStatusCode': -1, 'error': 'An error occurred: $e'};
      log(e.toString());
    }
    return data;
  }

  Future<Map<String, dynamic>> post({
    required Uri url,
    required bool isFormData,
    Map<String, dynamic> requestBody = const {},
    Map<String, String> headers = const {},
  }) async {
    Map<String, dynamic> data = {};
    try {
      if (isFormData) {
        headers['Content-Type'] = 'multipart/form-data';
        final http.MultipartRequest request = http.MultipartRequest(
          'POST',
          url,
        );
      } else {
        headers['Content-Type'] = 'application/json';
      }
      final response = await http
          .post(
            url,
            body: isFormData ? {} : json.encode(requestBody),
            headers: headers,
          )
          .timeout(
            Duration(seconds: timeoutInSeconds),
            onTimeout: () =>
                http.Response('{"error":"Request timed out"}', 408),
          );
      data = json.decode(response.body);
      data.addAll({'httpStatusCode': response.statusCode});
    } catch (e) {
      data = {'httpStatusCode': -1, 'error': 'An error occurred: $e'};
      log(e.toString());
    }
    return data;
  }

  Future<Map<String, dynamic>> put({
    required Uri url,
    Map<String, dynamic> requestBody = const {},
    Map<String, String> headers = const {},
  }) async {
    Map<String, dynamic> data = {};
    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(
            Duration(seconds: timeoutInSeconds),
            onTimeout: () =>
                http.Response('{"error":"Request timed out"}', 408),
          );
      data = json.decode(response.body);
      data.addAll({'httpStatusCode': response.statusCode});
    } catch (e) {
      data = {'httpStatusCode': -1, 'error': 'An error occurred: $e'};
      log(e.toString());
    }
    return data;
  }
}
