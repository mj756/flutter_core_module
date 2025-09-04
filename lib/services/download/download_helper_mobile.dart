import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter_core_module/enums.dart';
import 'package:flutter_core_module/streams/app_events.dart';
import 'package:flutter_core_module/utils/helper_service.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_core_module/services/logger_service.dart';
import 'package:flutter_core_module/services/download/download_service.dart';
import 'package:intl/intl.dart';

class DownloadMessage {

  DownloadMessage({required this.url,required this.progress,this.filePath});
  final double progress;
  final String url;
  final String? filePath;
}

class DownloadServiceMobile implements DownloadService {
  @override
  Future<String?> download({required String url,String newFileName='',String? downloadPath}) async {
    final receivePort = ReceivePort();
    String path = '';
    try {
       String path=downloadPath??'';
       String fName=newFileName.replaceAll(' ','').trim();

       if(path.isEmpty){
         path=await HelperService().getDownloadDirectory();
       } try{
          Directory d=Directory(path);
       }catch(e){
         path=await HelperService().getDownloadDirectory();
       }
      Map<String, dynamic> param = {'url': url,
        'fileName':newFileName,
        'sendPort':receivePort.sendPort,
        'path':path,
      };
      Isolate isolate = await Isolate.spawn(_isolateEntryPoint, param);

      await for (var message in receivePort) {
        if (message is DownloadMessage) {

          AppEventsStream().addEvent(
            AppEvent(type: AppEventType.downloadProgress, data: message),
          );
          if (message.filePath != null) {
            path=message.filePath??'';
            break;
          }
        }
      }
      path = await receivePort.last;
      isolate.kill(priority: Isolate.immediate);
    } catch (e) {
      LoggerService().log(message: e);
    }finally {
      receivePort.close();
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
        final dir =Directory(param['path']);
        String newFileName=param['fileName']??'';
        if(newFileName.isEmpty || newFileName.contains('.')==false){

          newFileName=param['url'];
          newFileName=newFileName.substring(newFileName.lastIndexOf('/')+1);
        }else{
          String ext=newFileName.substring(newFileName.lastIndexOf('.')+1);
          newFileName='${DateFormat('yyyy_mm_dd_hh_mm_ss').format(DateTime.now())}.$ext';
        }
        final file = File('${dir.path}/$newFileName');
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
                  sendPort.send(DownloadMessage(progress: double.tryParse(progress)??0,url: param['url']));
                  LoggerService().log(message: 'Download Progress $progress',level: LogLevel.info);
                }
              },
              onDone: () async {
                path = file.path;
                sendPort.send(DownloadMessage(progress: 100,url: param['url'],filePath: file.path));
                await sink.close();
              },
              onError: (e) {
                LoggerService().log(message: 'Download error $e',level: LogLevel.info);
              },
              cancelOnError: true,
            )
            .asFuture();

        path = file.path;
      } else {
        LoggerService().log(message: 'error occurred while downloading file');

      }
    } catch (ex) {
      sendPort.send(DownloadMessage(progress: 0,url: param['url']));
      LoggerService().log(message: 'error occurred while downloading file ${ex.toString()}');

    }
    sendPort.send(DownloadMessage(progress: 100,url: param['url'],filePath: path));
    //sendPort.send(path);
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
