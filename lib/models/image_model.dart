import 'dart:io';

class ImageModel {
  final File file;
  final int folderId;
  bool _selected = false;

  int? id;

  ImageModel({this.id, required this.file, required this.folderId});

  void toggleSelect() {
    _selected = !_selected;
  }

  bool isSelected() {
    return _selected;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'path': file.path,
      'folder_id': folderId,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      id: map['id'],
      file: File(map['path']),
      folderId: map['folder_id'],
    );
  }
}
