import 'dart:io';
import 'dart:isolate';

import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webp_to_gif/providers/folders_provider.dart';

import '../models/image_model.dart';

class ImageConverter {
  final ImageModel imgModel;
  final FoldersProvider folderProvider;

  ImageConverter({
    required this.imgModel,
    required this.folderProvider,
  });

  Future<bool> convert() async {
    final dir = await getApplicationSupportDirectory();

    var receivePort = ReceivePort();

    await Isolate.spawn(
      _convertIsolate,
      DecodeParam(imgModel.file, dir.path, receivePort.sendPort),
    );

    File? convertedFile = await receivePort.first as File?;

    if (convertedFile != null) {
      imgModel.file = convertedFile;
      imgModel.converted = true;
      folderProvider.updateImage(imgModel);
      return true;
    }

    return false;
  }
}

class DecodeParam {
  final File originalFile;
  final String dir;
  final SendPort sendPort;

  DecodeParam(this.originalFile, this.dir, this.sendPort);
}

void _convertIsolate(DecodeParam param) async {
  var image = decodeWebPAnimation(param.originalFile.readAsBytesSync());

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
