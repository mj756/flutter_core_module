import 'package:flutter_core_module/enums.dart';
import 'package:flutter_core_module/services/download/download_service.dart';

class DownloadServiceWeb implements DownloadService {
  @override
  Future<String?> download({required String url}) async {
    try {

    } catch (e) {
      //
    }
    return '';
  }
  @override
  Future<void> uploadFile({required String path,required String url,required ApiMethod method,
    required Function(double) onProgress,
    required Function(String) onError
  })async{
    try{

    }catch(e){
//
    }
  }
}
