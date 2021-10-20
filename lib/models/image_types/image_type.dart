import 'package:webp_to_gif/models/image_types/gif.dart';
import 'package:webp_to_gif/models/image_types/jpg.dart';
import 'package:webp_to_gif/models/image_types/mp4.dart';
import 'package:webp_to_gif/models/image_types/png.dart';
import 'package:webp_to_gif/models/image_types/webp.dart';

abstract class ImageType {
  String mime();
  String extension();
}

ImageType? getImageType(String extension) {
  switch (extension) {
    case '.jpg':
    case '.jpeg':
      return Jpg();
    case '.gif':
      return Gif();
    case '.png':
      return Png();
    case '.webp':
      return Webp();
    case '.mp4':
      return Mp4();
  }
}
