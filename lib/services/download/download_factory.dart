import 'package:flutter/foundation.dart';
import 'package:flutter_core_module/services/download/download_helper_mobile.dart'
    if (dart.library.io) 'download_helper_mobile.dart';
import 'package:flutter_core_module/services/download/download_helper_web.dart'
    if (dart.library.html) 'download_helper_web.dart';

import 'package:flutter_core_module/services/download/download_service.dart';

class DownloadFactory {
  static DownloadService getInstance() {
    if (kIsWeb) {
      return DownloadServiceWeb();
    } else {
      return DownloadServiceMobile();
    }
  }
}
