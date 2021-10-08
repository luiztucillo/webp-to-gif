import 'package:webp_to_gif/models/image_types/image_type.dart';

class Mp4 extends ImageType {
  @override
  String extension() {
    return 'mp4';
  }

  @override
  String mime() {
    return 'video/mp4';
  }
}
