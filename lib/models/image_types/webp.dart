import 'package:webp_to_gif/models/image_types/image_type.dart';

class Webp extends ImageType {
  @override
  String extension() {
    return 'webp';
  }

  @override
  String mime() {
    return 'image/webp';
  }
}
