import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core_module/services/download/download_factory.dart';
import 'package:flutter_core_module/utils/svg_helper/svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';

final class FileList {
  FileList({required this.url, this.storedFileName = ''});

  final String url;
  String storedFileName;
}

sealed class CachedFile {
  static List<FileList> cacheList = List.empty(growable: true);
}

class ImageWidget extends StatefulWidget {
  const ImageWidget({
    required this.url,
    this.height,
    this.width,
    super.key,
    this.color,
    this.fit,
    this.downloadCacheDirectory,
  });

  final String url;
  final double? height, width;
  final Color? color;
  final BoxFit? fit;
  final Directory? downloadCacheDirectory;

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  bool get _isUrl =>
      Uri.tryParse(widget.url) != null &&
      (Uri.tryParse(widget.url)!.scheme.isNotEmpty);

  bool get _isAssets => widget.url.toLowerCase().startsWith('assets/');

  bool get _isSvg => widget.url.toLowerCase().endsWith('.svg');

  String _existingPath = '';

  Future<bool> _isLocalPath() async {
    bool fileExist = false;
    try {
      if (kIsWeb) {
        return fileExist;
      }
      if (_isUrl == false && _isAssets == false) {
        fileExist = await File(widget.url).exists();
      }
    } catch (e) {
      //
    }
    return fileExist;
  }

  Future<void> _downloadOrCheckPath() async {
    try {
      String downloadPath = '';
      if (widget.downloadCacheDirectory != null) {
        downloadPath = widget.downloadCacheDirectory!.path;
      } else {
        await getApplicationCacheDirectory().then((d) {
          downloadPath = d.path;
        });
      }
      await DownloadFactory.getInstance()
          .download(url: widget.url, downloadPath: downloadPath)
          .then((t) {
            if (t != null && t.isNotEmpty) {
              _existingPath = t;
              CachedFile.cacheList.add(
                FileList(url: widget.url, storedFileName: t),
              );
            }
          });
    } catch (e) {
      //
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isUrl &&
          widget.downloadCacheDirectory != null &&
          CachedFile.cacheList.indexWhere((t) => t.url == widget.url) < 0) {
        Future.microtask(_downloadOrCheckPath);
      }
    });
    if (_isUrl) {
      if (kIsWeb) {
      } else if (widget.url.toLowerCase().endsWith('.svg') == false) {
      } else if (CachedFile.cacheList.indexWhere((t) => t.url == widget.url) >=
          0) {
        _existingPath = CachedFile.cacheList
            .firstWhere((t) => t.url == widget.url)
            .storedFileName;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_existingPath.isNotEmpty) {
      return _localImage(isSvg: _isSvg);
    } else if (_isAssets) {
      return _assetImage(isSvg: _isSvg);
    } else if (_isUrl) {
      return _networkImage(isSvg: _isSvg);
    } else {
      return _localImage(isSvg: _isSvg);
    }
  }

  Widget _assetImage({required bool isSvg}) {
    if (_isSvg) {
      return SvgPicture.asset(
        widget.url,
        width: widget.width,
        height: widget.height,
        fit: widget.fit ?? BoxFit.cover,
        colorFilter: widget.color != null
            ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
            : null,
        placeholderBuilder: (context) => SizedBox(
          width: widget.width,
          height: widget.height,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.error, color: Colors.red, size: widget.height),
      );
    } else {
      return Image.asset(
        widget.url,
        width: widget.width,
        height: widget.height,
        fit: widget.fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.error, color: Colors.red, size: widget.height),
      );
    }
  }

  Widget _networkImage({required bool isSvg}) {
    if (_isSvg) {
      return SvgPicture.network(
        widget.url,
        width: widget.width,
        height: widget.height,
        fit: widget.fit ?? BoxFit.cover,
        colorFilter: widget.color != null
            ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
            : null,
        placeholderBuilder: (context) => SizedBox(
          width: widget.width,
          height: widget.height,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.error, color: Colors.red, size: widget.height),
      );
    } else {
      return Image.network(
        widget.url,
        width: widget.width,
        height: widget.height,
        fit: widget.fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.error, color: Colors.red, size: widget.height),
      );
    }
  }

  Widget _localImage({required bool isSvg}) {
    return FutureBuilder(
      future: _isLocalPath(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Icon(
            Icons.access_time,
            color: Colors.red,
            size: widget.height,
          );
        } else if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data == true) {
          return LocalImageFactory.getInstance(
            isSvg: _isSvg,
            width: widget.width,
            height: widget.height,
            fit: widget.fit ?? BoxFit.cover,
            url: widget.url,
          );
        } else {
          return Icon(Icons.error, color: Colors.red, size: widget.height);
        }
      },
    );
  }
}
