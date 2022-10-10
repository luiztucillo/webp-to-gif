import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webp_to_gif/models/converter_actions/convert.dart';
import 'package:webp_to_gif/models/converter_actions/resize.dart';
import 'package:webp_to_gif/models/image_types/gif.dart';
import 'package:webp_to_gif/models/image_types/jpg.dart';
import 'package:webp_to_gif/models/image_types/mp4.dart';
import 'package:webp_to_gif/models/image_types/png.dart';
import 'package:webp_to_gif/models/image_types/webp.dart';

import '../models/image_model.dart';

typedef ConversionCallback = void Function(ImageModel);

class QueueItem {
  final ImageModel imageModel;
  final ConversionCallback onConversionDone;
  final Convert action;

  QueueItem({
    required this.imageModel,
    required this.onConversionDone,
    required this.action,
  });
}

class DecodeParam {
  final ImageModel imageModel;
  final SendPort sendPort;
  final Animation? animation;

  DecodeParam(this.imageModel, this.sendPort, this.animation);
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

    if (imgModel.imageType is Jpg) {
      var name = '${imgModel.folder.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      imgModel.file.copy(name);
      imgModel.file = File(name);
      imgModel.converted = true;
      onConversionDone(imgModel);
      return;
    }

    if (imgModel.imageType is Png) {
      var name = '${imgModel.folder.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      imgModel.file.copy(name);
      imgModel.file = File(name);
      imgModel.converted = true;
      onConversionDone(imgModel);
      return;
    }

    queue.add(QueueItem(
      imageModel: imgModel,
      onConversionDone: onConversionDone,
      action: Convert(),
    ));

    if (!running) {
      _exec();
    }
  }

  resize(ImageModel imgModel, int toWidth, int toHeight, int frameRate, ConversionCallback onConversionDone) {
    queue.add(QueueItem(
      imageModel: imgModel,
      onConversionDone: onConversionDone,
      action: Resize(width: toWidth, height: toHeight, frameRate: frameRate),
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

    File? convertedFile;

    if (queueItem.action is Convert) {
      if (queueItem.imageModel.imageType is Webp) {
        convertedFile = await _convertWebp(queueItem.imageModel);
      } else if (queueItem.imageModel.imageType is Mp4) {
        convertedFile = await _convertMp4(queueItem.imageModel);
      }
    }

    if (queueItem.action is Resize) {
      var resize = queueItem.action as Resize;
      convertedFile = await _resizeGif(queueItem.imageModel, resize.width, resize.height, resize.frameRate);
    }

    if (convertedFile != null) {
      queueItem.imageModel.file = convertedFile;
      queueItem.imageModel.thumbnail = convertedFile;
      queueItem.imageModel.converted = true;
      queueItem.imageModel.imageType = Gif();
      queueItem.onConversionDone(queueItem.imageModel);
    }

    converting = null;

    _exec();
  }
}

Future<File?> _convertMp4(ImageModel imageModel) async {

  var name = '${DateTime.now().millisecondsSinceEpoch}.gif';

  var path = '${imageModel.folder.path}/$name';
  var tmp = (await getTemporaryDirectory()).path + '/$name';

  var arguments = [
    '-i',
    imageModel.file.path,
    '-loop',
    '0',
    '-r',
    '10',
    tmp
  ];

  try {
    FlutterFFmpeg _ffmpeg = FlutterFFmpeg();
    await _ffmpeg.executeWithArguments(arguments);

    var file = File(tmp);

    if (await file.length() == 0) {
      return null;
    }

    file.copySync(path);

    return File(path);
  } catch (e) {
    return null;
  }
}

Future<File?> _resizeGif(ImageModel imageModel, int toWidth, int toHeight, int frameRate) async {
  var name = '${DateTime.now().millisecondsSinceEpoch}.gif';
  var path = '${imageModel.folder.path}/$name';
  var tmp = (await getTemporaryDirectory()).path + '/$name';

  var arguments = [
    '-y',
    '-i', imageModel.file.path,
    '-vf',
    'scale=$toWidth:$toHeight',
    '-r',
    '$frameRate',
    tmp,
  ];

  try {
    FlutterFFmpeg _ffmpeg = FlutterFFmpeg();
    await _ffmpeg.executeWithArguments(arguments);

    var file = File(tmp);

    if (await file.length() == 0) {
      return null;
    }

    file.copySync(path);

    return File(path);
  } catch (e) {
    return null;
  }
}

Future<File?> _convertWebp(ImageModel imageModel) async {
  var receivePort = ReceivePort();

  await Isolate.spawn(
    _convertWebpIsolate,
    DecodeParam(imageModel, receivePort.sendPort, null),
  );

  return await receivePort.first as File?;
}

void _convertWebpIsolate(DecodeParam param) async {
  var image = decodeWebPAnimation(param.imageModel.file.readAsBytesSync());

  if (image == null) {
    param.sendPort.send(null);
    return;
  }

  param.sendPort.send(await _encode(image, param.imageModel.folder.path));
}

Future<File?> _encode(Animation image, String path) async {
  try {
    var name = '$path/${DateTime.now().millisecondsSinceEpoch}.gif';
    File file = File(name);

    if (image.numFrames == 1) {
      file.writeAsBytesSync(encodeGif(image.frames.first, samplingFactor: 100), flush: true);
    } else {
      file.writeAsBytesSync(encodeGifAnimation(image, samplingFactor: 100)!, flush: true);
    }

    return file;
  } catch (e) {
    //
  }
}
