import 'dart:io';
import 'dart:isolate';

import 'package:webp_to_gif/services/folders_service.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';

class ImageConverter {
  final List<String> filePaths;

  ImageConverter({
    required this.filePaths,
  });

  Future<List<File>> convert(FoldersService foldersService) async {
    final dir = await getApplicationSupportDirectory();

    List<File> result = [];

    for (var path in filePaths) {
      var receivePort = ReceivePort();
      await Isolate.spawn(
        _convertIsolate,
        DecodeParam(path, dir.path, receivePort.sendPort),
      );

      File? file = await receivePort.first as File?;

      if (file != null) {
        result.add(file);
        foldersService.addImage(file);
      }
    }

    return result;
  }
}

class DecodeParam {
  final String path;
  final String dir;
  final SendPort sendPort;

  DecodeParam(this.path, this.dir, this.sendPort);
}

void _convertIsolate(DecodeParam param) async {
  var image = decodeWebPAnimation(File(param.path).readAsBytesSync());

  if (image == null) {
    param.sendPort.send(null);
    return;
  }

  try {
    var name = '${param.dir}/${DateTime.now().millisecondsSinceEpoch}.gif';
    File file = File(name);

    if (image.numFrames == 1) {
      file.writeAsBytesSync(encodeGif(image.frames.first, samplingFactor: 100), flush: true);
    } else {
      file.writeAsBytesSync(encodeGifAnimation(image, samplingFactor: 100)!, flush: true);
    }

    param.sendPort.send(file);
  } catch (e) {
    param.sendPort.send(null);
  }
}
