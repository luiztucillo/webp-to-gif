import 'dart:io';

class ImageModel {
  final int folderId;
  bool converted;
  File file;

  bool _selected = false;

  int? id;

  ImageModel({
    required this.folderId,
    required this.file,
    required this.converted,
    this.id,
  });

  void toggleSelect() {
    _selected = !_selected;
  }

  bool isSelected() {
    return _selected;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'folder_id': folderId,
      'file': file.path,
      'converted': converted ? 1 : 0,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      folderId: map['folder_id'],
      file: File(map['file']),
      converted: map['converted'] == 1 ? true : false,
      id: map['id'],
    );
  }
}
