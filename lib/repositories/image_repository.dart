import 'dart:io';

import 'package:webp_to_gif/models/folder_model.dart';
import 'package:webp_to_gif/services/db_service.dart';

class ImageRepository {
  static final ImageRepository _instance =
      ImageRepository._internalConstructor();

  factory ImageRepository() {
    return _instance;
  }

  ImageRepository._internalConstructor();

  final String table = 'images';

  Future<int?> create(File file, FolderModel folder) async {
    var map = {'path': file.path, 'folder_id': folder.id};

    int? id = await DbService().insert(table, map);

    if (id == null) {
      return null;
    }

    return id;
  }

  Future<List<File>> list(FolderModel folder) async {
    var maped = await DbService().query(
      table,
      ['id', 'path', 'folder_id'],
      where: 'folder_id = ?',
      whereArgs: [folder.id],
    );

    if (maped == null) {
      return [];
    }

    List<File> result = [];

    for (var map in maped) {
      result.add(File(map['path']));
    }

    return result;
  }
}
