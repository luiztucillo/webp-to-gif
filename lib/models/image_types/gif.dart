import 'package:webp_to_gif/models/image_types/image_type.dart';

class Gif extends ImageType {
  @override
  String extension() {
    return 'gif';
  }

  @override
  String mime() {
    return 'image/gif';
  }
}
