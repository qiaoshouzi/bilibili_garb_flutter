import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as path;
import 'package:file_selector/file_selector.dart';
import 'package:bili_garb/models/bili_data_model.dart';

class SaveMediaModel {
  Future<String?> saveMedia(FileType type, CardData data) async {
    final String? url;
    switch (type) {
      case FileType.image:
        url = data.img;
        break;
      case FileType.video:
        url = data.videos?[0];
        break;
    }
    if (url == null) throw ('url is null');

    final String randomName =
        '${DateTime.now().millisecondsSinceEpoch}_${url.hashCode}';
    final String extension = path.extension(Uri.parse(url).path);
    final String fileName = randomName + extension;

    final String? downloadPath;
    final bool saveToGal;
    if (Platform.isAndroid || Platform.isIOS) {
      downloadPath = '${Directory.systemTemp.path}/$fileName';
      saveToGal = true;
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final FileSaveLocation? result = await getSaveLocation(
        suggestedName: fileName,
      );
      downloadPath = result?.path;
      saveToGal = false;
    } else {
      throw ('该平台未支持');
    }
    if (downloadPath is! String) return null;

    String? returnMsg;
    Object? error;
    try {
      await Dio().download(url, downloadPath);
      if (saveToGal) {
        if (type == FileType.image) {
          await Gal.putImage(downloadPath);
        } else if (type == FileType.video) {
          await Gal.putVideo(downloadPath);
        }
      }
      returnMsg = '已保存到 ${saveToGal ? '相册' : downloadPath}';
    } catch (e) {
      error = e;
    } finally {
      if (saveToGal) {
        try {
          final file = File(downloadPath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          throw ('清理临时文件失败: $e');
        }
      }
    }
    if (error is Object) throw (error);
    if (returnMsg is String) return returnMsg;
    return null;
  }
}
