import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:image/image.dart';
import 'package:webp_to_gif/models/image_types/gif.dart';

import '../models/image_model.dart';

typedef ConversionCallback = void Function(ImageModel);

class QueueItem {
  final ImageModel imageModel;
  final ConversionCallback onConversionDone;

  QueueItem({required this.imageModel, required this.onConversionDone});
}

class DecodeParam {
  final ImageModel imageModel;
  final SendPort sendPort;

  DecodeParam(this.imageModel, this.sendPort);
}

class ImageConverter {
  static final ImageConverter _instance = ImageConverter._internalConstructor();

  factory ImageConverter() {
    return _instance;
  }

  ImageConverter._internalConstructor();

  final Queue<QueueItem> queue = Queue();
  ImageModel? converting;

  bool running = false;

  Future<void> convert(
    ImageModel imgModel,
    ConversionCallback onConversionDone,
  ) async {
    if (imgModel.imageType is Gif) {
      var name = '${imgModel.folder.path}/${DateTime.now().millisecondsSinceEpoch}.gif';
      imgModel.file.copy(name);
      imgModel.file = File(name);
      imgModel.converted = true;
      onConversionDone(imgModel);
      return;
    }

    queue.add(QueueItem(
      imageModel: imgModel,
      onConversionDone: onConversionDone,
    ));

    if (!running) {
      _exec();
    }
  }

  Future<void> _exec() async {
    if (queue.isEmpty) {
      running = false;
      return;
    }

    running = true;
    QueueItem queueItem = queue.removeFirst();
    converting = queueItem.imageModel;

    var receivePort = ReceivePort();

    await Isolate.spawn(
      _convertIsolate,
      DecodeParam(queueItem.imageModel, receivePort.sendPort),
    );

    File? convertedFile = await receivePort.first as File?;

    if (convertedFile != null) {
      queueItem.imageModel.file = convertedFile;
      queueItem.imageModel.converted = true;
      queueItem.imageModel.imageType = Gif();
      queueItem.onConversionDone(queueItem.imageModel);
    }

    converting = null;

    _exec();
  }
}

void _convertIsolate(DecodeParam param) async {
  var image = decodeWebPAnimation(param.imageModel.file.readAsBytesSync());

  if (image == null) {
    param.sendPort.send(null);
    return;
  }

  try {
    var name =
        '${param.imageModel.folder.path}/${DateTime.now().millisecondsSinceEpoch}.gif';
    File file = File(name);

    if (image.numFrames == 1) {
      file.writeAsBytesSync(encodeGif(image.frames.first, samplingFactor: 100),
          flush: true);
    } else {
      file.writeAsBytesSync(encodeGifAnimation(image, samplingFactor: 100)!,
          flush: true);
    }

    param.sendPort.send(file);
  } catch (e) {
    param.sendPort.send(null);
  }
}
