import 'package:webp_to_gif/models/folder_model.dart';
import 'package:flutter/material.dart';
import 'package:webp_to_gif/models/image_model.dart';
import 'package:webp_to_gif/repositories/folder_repository.dart';
import 'package:webp_to_gif/repositories/image_repository.dart';

class FoldersProvider extends ChangeNotifier {
  final List<FolderModel> _items = [];
  bool loading = false;
  FolderModel? currentFolder;

  FoldersProvider({this.currentFolder}) {
    init();
  }

  init() async {
    _items.addAll(await FolderRepository().list());

    if (currentFolder != null) {
      currentFolder!.resetImages();
      var images = await ImageRepository().list(currentFolder!);

      for (ImageModel image in images) {
        currentFolder!.addImage(image);
      }
    }

    notifyListeners();
  }

  List<FolderModel> get items => _items;

  void setLoading(bool isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  void add(FolderModel folder) async {
    await FolderRepository().create(folder);
    _items.add(folder);
    notifyListeners();
  }

  Future<void> remove(FolderModel folder) async {
    for (FolderModel fdr in _items) {
      if (fdr.id == folder.id) {
        for (ImageModel image in folder.images) {
          try {
            image.file.delete();
          } catch (e) {
            //
          }
        }

        await ImageRepository().delete(folder);

        folder.resetImages();

        await FolderRepository().delete(fdr);

        _items.remove(fdr);

        break;
      }
    }
    notifyListeners();
  }

  Future<void> removeImage(ImageModel image) async {
    if (currentFolder == null) {
      return;
    }

    if (image.folderId != currentFolder!.id) {
      return;
    }

    var result = await ImageRepository().deleteImage(image);

    if (result == false) {
      return;
    }

    image.file.delete();

    currentFolder!.images.removeWhere((ImageModel img) => img.id == image.id);

    for (FolderModel fdr in _items) {
      if (fdr.id == currentFolder!.id) {
        fdr.images.removeWhere((ImageModel img) => img.id == image.id);
      }
    }

    notifyListeners();
  }

  void removeAll() {
    _items.clear();
    notifyListeners();
  }

  void addImage(ImageModel image) async {
    if (currentFolder == null) {
      return;
    }

    var id = await ImageRepository().create(image, currentFolder!);

    if (id != null) {
      image.id = id;
      currentFolder!.addImage(image);
    }

    notifyListeners();
  }

  void updateImage(ImageModel image) async {
    await ImageRepository().update(image);

    if (hasListeners) {
      notifyListeners();
    }
  }
}
