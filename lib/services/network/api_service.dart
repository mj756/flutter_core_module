import 'package:http_interceptor/models/interceptor_contract.dart';

export 'api_service.dart'
if (dart.library.io) 'api_mobile.dart'
if (dart.library.html) 'api_web.dart';
abstract class NetworkService{
  void setInterceptors({required InterceptorContract interceptor});
  Future<Map<String, dynamic>> get({
    required String url,
  });
  Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, dynamic> requestBody,
    required bool isFormData,
  });
  Future<Map<String, dynamic>> put({
    required String url,
    required Map<String, dynamic> requestBody,
    required bool isFormData,
  });
  Future<Map<String, dynamic>> delete({
    required String url,
    required Map<String, dynamic> requestBody,
    required bool isFormData,
  });
  void setTimeOut({required int durationInSeconds});
  Future<bool> hasInternet();
}