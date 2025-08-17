import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;

import '../logger_service.dart';
import 'download_service.dart';

class DownloadServiceMobile implements DownloadService {
  @override
  Future<String?> download({required String url}) async {
    final receivePort = ReceivePort();
    String path = '';
    try {
      Map<String, dynamic> param = {'url': url};
      Isolate isolate = await Isolate.spawn(_isolateEntryPoint, param);
      path = await receivePort.first;
      isolate.kill(priority: Isolate.immediate);
      receivePort.close();
    } catch (e) {
      LoggerService().log(message: e);
    }
    return path;
  }

  Future<void> _isolateEntryPoint(Map<String, dynamic> param) async {
    final SendPort sendPort = param['sendPort'] as SendPort;
    String path = '';
    try {
      final request = http.Request('GET', Uri.parse(param['url']));
      final response = await http.Client().send(request);

      if (response.statusCode == 200) {
        final dir = Directory(param['path']);
        final file = File("${dir.path}/$param['fileName']");
        final sink = file.openWrite();
        final contentLength = response.contentLength ?? 0;
        int downloaded = 0;
        await response.stream
            .listen(
              (chunk) {
                downloaded += chunk.length;
                sink.add(chunk);

                if (contentLength > 0) {
                  final progress = (downloaded / contentLength * 100)
                      .toStringAsFixed(2);
                  print("Progress: $progress %");
                }
              },
              onDone: () async {
                await sink.close();
                print("Download completed: ${file.path}");
              },
              onError: (e) {
                throw Exception("Download failed: $e");
              },
              cancelOnError: true,
            )
            .asFuture();

        path = file.path;
      } else {
        throw Exception("Failed to download file: ${response.statusCode}");
      }
    } catch (ex) {
      LoggerService().log(message: ex);
    }
    sendPort.send(path);
  }
}
