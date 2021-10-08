import 'package:mime_type/mime_type.dart';
import 'package:webp_to_gif/models/image_types/gif.dart';
import 'package:webp_to_gif/models/image_types/image_type.dart';
import 'package:webp_to_gif/models/image_types/jpg.dart';
import 'package:webp_to_gif/models/image_types/mp4.dart';
import 'package:webp_to_gif/models/image_types/png.dart';
import 'package:webp_to_gif/models/image_types/webp.dart';

class Type {
  static ImageType getType(String path) {

    final mimeType = mime(path);

    switch (mimeType) {
      case 'image/gif':
        return Gif();
      case 'image/png':
        return Png();
      case 'image/webp':
        return Webp();
      case 'image/jpg':
        return Jpg();
      case 'video/mp4':
        return Mp4();
    }

    throw Exception('Invalid image type: $mimeType');
  }
}
