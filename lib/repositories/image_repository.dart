import 'package:webp_to_gif/models/folder_model.dart';
import 'package:webp_to_gif/models/image_model.dart';
import 'package:webp_to_gif/services/db_service.dart';

class ImageRepository {
  static final ImageRepository _instance =
      ImageRepository._internalConstructor();

  factory ImageRepository() {
    return _instance;
  }

  ImageRepository._internalConstructor();

  final String table = 'images';

  Future<int?> create(ImageModel image, FolderModel folder) async {
    int? id = await DbService().insert(table, image.toMap());

    if (id == null) {
      return null;
    }

    return id;
  }

  Future<List<ImageModel>> list(FolderModel folder) async {
    var maped = await DbService().query(
      table,
      ['id', 'path', 'folder_id'],
      where: 'folder_id = ?',
      whereArgs: [folder.id],
    );

    if (maped == null) {
      return [];
    }

    List<ImageModel> result = [];

    for (var map in maped) {
      result.add(ImageModel.fromMap(map));
    }

    return result;
  }

  Future delete(FolderModel folder) async {
    if (folder.id == null) {
      return null;
    }

    return await DbService().deleteWhere(table, 'folder_id = ?', [folder.id]);
  }
}
