import 'package:flutter/foundation.dart';
import 'package:flutter_core_module/services/network/api_service.dart';

import 'package:flutter_core_module/services/network/api_mobile.dart'
if (dart.library.io) 'api_mobile.dart';
import 'package:flutter_core_module/services/network/api_web.dart'
if (dart.library.html) 'api_web.dart';

class NetworkFactory {
  static NetworkService getInstance() {
    if (kIsWeb) {
      return NetworkServiceWeb();
    } else {
      return NetworkServiceMobile();
    }
  }
}
