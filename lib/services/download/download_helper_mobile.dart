import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter_core_module/enums.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_core_module/services/logger_service.dart';
import 'package:flutter_core_module/services/download/download_service.dart';

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
                  LoggerService().log(message: 'Download Progress $progress',level: LogLevel.info);
                }
              },
              onDone: () async {
                await sink.close();
              },
              onError: (e) {
                throw Exception('Download failed: $e');
              },
              cancelOnError: true,
            )
            .asFuture();

        path = file.path;
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (ex) {
      LoggerService().log(message: ex);
    }
    sendPort.send(path);
  }

  void _uploadFileIsolate(Map<String, dynamic> param) async{
    final sendPort=param['sendPort'] as SendPort;
    try{

           final file = File(param['localPath']);
            FileStat fileStat=await file.stat();
            final totalBytes = fileStat.size;
            int uploadedBytes = 0;
            final uri = Uri.parse(param['url']);
            final ApiMethod method=param['methods'];
            late final http.MultipartRequest request;

            switch(method){
              case ApiMethod.post:
                request=http.MultipartRequest('POST', uri);
                  break;
              case ApiMethod.put:
                request=http.MultipartRequest('PUT', uri);
                break;
              case ApiMethod.get:
                request=http.MultipartRequest('GET', uri);
                break;
              case ApiMethod.delete:
                request=http.MultipartRequest('DELETE', uri);
               break;
            }

           final stream = file.openRead().transform<List<int>>(
             StreamTransformer.fromHandlers(
               handleData: (List<int> chunk, EventSink<List<int>> sink) {
                 uploadedBytes += chunk.length;
                 final progress = (uploadedBytes / totalBytes) * 100;

                 sendPort.send({
                   'status': 'progress',
                   'progress': progress,
                   'bytes': uploadedBytes,
                   'total': totalBytes,
                 });
                 LoggerService().log(message: 'progress====>$progress');

                 sink.add(chunk); // forward chunk
               },
             ),
           );
            LoggerService().log(message: 'preparing upload file request');
           final multipartFile = http.MultipartFile(
             'file',
             stream,
             totalBytes,
             filename: Uri.file(param['localPath']).pathSegments.last,
           );
           request.files.add(multipartFile);
           final response = await request.send();
           LoggerService().log(message: 'file upload response status===>${response.statusCode}');
           if(response.statusCode >= 200 && response.statusCode < 300){
             sendPort.send(100.0);
           }else{
             sendPort.send('invalid http response');
           }

      }catch(e){
        sendPort.send(e.toString());
      }

  }
  @override
  Future<void> uploadFile({required String path,required String url,required ApiMethod method,
    required Function(double) onProgress,
    required Function(String) onError
  })async{
    try{
      final receivePort = ReceivePort();
      receivePort.listen((message) {
        if (message is double) {
          if(message==100.0){
            onProgress(message);
          }

        }
        else if (message is String) {
          onError(message);
          receivePort.close();
        }
      });
      final param={
        'localPath':path,
        'sendPort':receivePort.sendPort,
        'url':url,
        'methods':method,
      };
      LoggerService().log(message: 'calling file upload isolate');
      await Isolate.spawn(
        _uploadFileIsolate,
        param,
      );
    }catch(e){
//
    }
  }
}
