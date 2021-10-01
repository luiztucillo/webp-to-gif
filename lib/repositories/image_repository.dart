import 'dart:io';

import 'package:webp_to_gif/models/folder_model.dart';
import 'package:webp_to_gif/models/image_model.dart';

class ImageRepository {
  static final ImageRepository _instance =
      ImageRepository._internalConstructor();

  factory ImageRepository() {
    return _instance;
  }

  ImageRepository._internalConstructor();

  Future<int?> create(ImageModel image, FolderModel folder) async {}

  Future<List<ImageModel>> list(FolderModel folder) async {
    final Directory _appDirFolder = Directory(folder.path);

    List<FileSystemEntity> list = _appDirFolder.listSync();

    List<ImageModel> imageList = [];

    for (var img in list) {
      if (FileSystemEntity.isFileSync(img.path)) {
        imageList.add(ImageModel(
          folder: folder,
          file: File(img.path),
          converted: true,
        ));
      }
    }

    return imageList;
  }

  Future<bool> delete(ImageModel img) async {
    try {
      img.file.deleteSync();
      return true;
    } catch (e) {
      return false;
    }
  }
}
