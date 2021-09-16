import 'package:webp_to_gif/models/folder_model.dart';
import 'package:webp_to_gif/services/db_service.dart';

class FolderRepository{
  static final FolderRepository _instance = FolderRepository._internalConstructor();

  factory FolderRepository() {
    return _instance;
  }

  FolderRepository._internalConstructor();

  final String table = 'folders';

  Future<int?> create(FolderModel folder) async {
    int? id = await DbService().insert(table, folder.toMap());

    if (id == null) {
      return null;
    }

    folder.id = id;

    return id;
  }

  Future<bool?> update(FolderModel folder) async {
    if (folder.id == null) {
      return null;
    }

    return await DbService().update(table, folder.toMap());
  }

  Future<bool?> delete(FolderModel folder) async {
    if (folder.id == null) {
      return null;
    }

    return await DbService().delete(table, folder.id!);
  }

  Future<List<FolderModel>> list() async {
    var maped = await DbService().query(table, ['id', 'name', 'color']);

    if (maped == null) {
      return [];
    }

    List<FolderModel> result = [];

    for (var map in maped) {
      result.add(FolderModel.fromMap(map));
    }

    return result;
  }
}
