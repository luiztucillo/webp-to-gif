import 'package:webp_to_gif/models/image_types/image_type.dart';

class Jpg extends ImageType {
  @override
  String extension() {
    return 'jpeg';
  }

  @override
  String mime() {
    return 'image/jpeg';
  }
}
