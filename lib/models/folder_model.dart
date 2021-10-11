import 'dart:io';

class FolderModel {
  final String name;
  final String path;
  File? cover;
  int? filesCount;

  FolderModel({
    required this.name,
    required this.path,
    this.cover,
    this.filesCount,
  });
}
