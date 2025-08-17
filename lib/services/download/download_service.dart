import 'dart:async' if (dart.library.isolate) 'dart:isolate';

export 'download_service.dart'
    if (dart.library.io) 'download_helper_mobile.dart'
    if (dart.library.html) 'download_helper_web.dart';

abstract class DownloadService {
  Future<String?> download({required String url});
}
