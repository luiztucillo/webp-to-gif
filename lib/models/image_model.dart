import 'dart:io';

class ImageModel {
  final int folderId;
  File? file;
  bool _selected = false;
  String? path;

  int? id;

  ImageModel({
    required this.folderId,
    this.id,
    this.file,
    this.path,
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
    };

    if (file != null) {
      map['path'] = file!.path;
    }

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
