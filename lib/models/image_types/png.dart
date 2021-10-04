import 'package:webp_to_gif/models/image_types/image_type.dart';

class Png extends ImageType {
  @override
  String extension() {
    return 'png';
  }

  @override
  String mime() {
    return 'image/png';
  }
}
