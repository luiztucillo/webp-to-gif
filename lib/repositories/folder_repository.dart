import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:webp_to_gif/models/folder_model.dart';

class FolderRepository {
  static final FolderRepository _instance =
      FolderRepository._internalConstructor();

  factory FolderRepository() {
    return _instance;
  }

  FolderRepository._internalConstructor();

  final String table = 'folders';

  Future<String> _basePath() async {
    return (await getApplicationDocumentsDirectory()).path + '/app_folders';
  }

  Future<FolderModel?> create(String name) async {
    final Directory _appDir = Directory('${await _basePath()}/$name/');

    if (await _appDir.exists()) {
      return null;
    }

    final Directory _appDirNew = await _appDir.create(recursive: true);

    return FolderModel(
      name: name,
      path: _appDirNew.path,
    );
  }

  Future<bool> delete(FolderModel folder) async {
    final Directory _appDirFolder =
        Directory('${await _basePath()}/${folder.name}/');

    try {
      _appDirFolder.delete(recursive: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<FolderModel>> list() async {
    try {
      final Directory _appDirFolder = Directory(await _basePath());

      List<FileSystemEntity> list = _appDirFolder.listSync();

      List<FolderModel> folderList = [];

      for (var fdr in list) {
        if (FileSystemEntity.isDirectorySync(fdr.path)) {
          folderList.add(FolderModel(
            name: fdr.path
                .split('/')
                .last,
            path: fdr.path,
          ));
        }
      }

      return folderList;
    }  catch(e) {
      return [];
    }
  }
}
