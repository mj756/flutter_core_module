import 'dart:async' if (dart.library.isolate) 'dart:isolate';
import 'package:flutter_core_module/enums.dart';

export 'download_service.dart'
    if (dart.library.io) 'download_helper_mobile.dart'
    if (dart.library.html) 'download_helper_web.dart';

abstract class DownloadService {
  Future<String?> download({required String url,String newFileName='',String? downloadPath});
  Future<void> uploadFile({required String path,required String url,required ApiMethod method,
    required Function(double) onProgress,
    required Function(String) onError
  });
}
