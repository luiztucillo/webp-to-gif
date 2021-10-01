import 'dart:io';

import 'folder_model.dart';

class ImageModel {
  final FolderModel folder;
  bool converted;
  File file;

  bool _selected = false;

  ImageModel({
    required this.folder,
    required this.file,
    required this.converted,
  });

  void toggleSelect() {
    _selected = !_selected;
  }

  bool isSelected() {
    return _selected;
  }
}
