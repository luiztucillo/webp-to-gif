import 'package:webp_to_gif/models/converter_actions/convert.dart';

class Resize extends Convert {
  final int width;
  final int height;
  final int frameRate;

  Resize({
    required this.width,
    required this.height,
    required this.frameRate,
  });
}
