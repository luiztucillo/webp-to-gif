import 'dart:io';

import 'folder_model.dart';
import 'image_types/image_type.dart';

class ImageModel {
  final FolderModel folder;
  ImageType imageType;
  bool converted;
  File file;
  File? thumbnail;
  late DateTime updatedAt;

  bool _selected = false;

  ImageModel({
    required this.folder,
    required this.file,
    required this.converted,
    required this.imageType,
    this.thumbnail,
  }) {
    final stat = FileStat.statSync(file.path);
    updatedAt = stat.modified;
  }

  void toggleSelect() {
    _selected = !_selected;
  }

  bool isSelected() {
    return _selected;
  }
}
