import 'dart:io';

import 'package:webp_to_gif/models/folder_model.dart';
import 'package:webp_to_gif/models/image_model.dart';
import 'package:path/path.dart' as p;
import 'package:webp_to_gif/models/image_types/image_type.dart';

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
        var file = File(img.path);
        var type = getImageType(p.extension(img.path));

        if (type == null) {
          file.deleteSync();
          continue;
        }

        imageList.add(
          ImageModel(
            folder: folder,
            file: file,
            converted: true,
            imageType: type,
          ),
        );
      }
    }

    imageList.sort((ImageModel a, ImageModel b) => a.updatedAt.isBefore(b.updatedAt) ? 0 : 1);

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
