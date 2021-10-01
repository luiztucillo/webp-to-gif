import 'dart:io';

import 'package:webp_to_gif/models/folder_model.dart';
import 'package:flutter/material.dart';
import 'package:webp_to_gif/models/image_model.dart';
import 'package:webp_to_gif/repositories/folder_repository.dart';
import 'package:webp_to_gif/repositories/image_repository.dart';
import 'package:webp_to_gif/services/image_converter.dart';

class FoldersProvider extends ChangeNotifier {
  final List<FolderModel> _items = [];
  final List<ImageModel> _convertingList = [];

  FolderModel? _currentFolder;
  List<ImageModel>? _currentImages;
  bool _converting = false;

  FolderModel? get currentFolder => _currentFolder;
  List<ImageModel>? get currentImages => _currentImages;
  bool get converting => _converting;

  List<FolderModel> get list => _items;

  FoldersProvider({FolderModel? folder}) {
    init();

    if (folder != null) {
      changeFolder(folder);
    }
  }

  Future<void> init() async {
    _items.addAll(await FolderRepository().list());
    notifyListeners();
  }

  Future<void> create(String name) async {
    _items.add(await FolderRepository().create(name));
    notifyListeners();
  }

  Future<void> remove(FolderModel folder) async {
    await FolderRepository().delete(folder);
    _items.remove(folder);
    notifyListeners();
  }

  Future<void> removeImage(ImageModel image) async {
    await ImageRepository().delete(image);
    _currentImages?.remove(image);
    notifyListeners();
  }

  void changeFolder(FolderModel? folder) async {
    _currentFolder = folder;

    _currentImages?.clear();

    if (folder != null) {
      _currentImages = await ImageRepository().list(folder);
    }
  }

  Future<void> convert(List<String> pathList) async {
    if (_currentFolder == null) {
      return;
    }

    _converting = true;

    List<ImageModel> imgModels = [];

    for (String path in pathList) {
      var mdl = ImageModel(
        folder: _currentFolder!,
        file: File(path),
        converted: false,
      );

      imgModels.add(mdl);
      _currentImages!.add(mdl);
    }

    notifyListeners();

    for (var mdl in imgModels) {
      _convertingList.add(mdl);
      await ImageConverter().convert(mdl, (ImageModel imageModel) {
        _convertingList.remove(imageModel);

        if (_convertingList.isEmpty) {
          _converting = false;
        }

        notifyListeners();
      });
    }
  }
}
