import 'package:webp_to_gif/models/folder_model.dart';
import 'package:flutter/material.dart';
import 'package:webp_to_gif/models/image_model.dart';
import 'package:webp_to_gif/repositories/folder_repository.dart';
import 'package:webp_to_gif/repositories/image_repository.dart';
import 'package:webp_to_gif/services/image_converter.dart';

class FoldersProvider extends ChangeNotifier {
  final List<FolderModel> _items = [];
  final List<ImageModel> _convertingList = [];
  bool _isDisposed = false;

  FolderModel? _currentFolder;
  List<ImageModel>? _currentImages;
  bool _converting = false;

  FolderModel? get currentFolder => _currentFolder;
  List<ImageModel>? get currentImages => _currentImages;
  bool get converting => _converting;

  List<FolderModel> get list => _items;
  int get folderCount => _items.length;

  FoldersProvider() {
    init();
  }

  Future<void> init() async {
    _items.clear();
    _items.addAll(await FolderRepository().list());
    customNotifyListeners();
  }

  Future<void> create(String name) async {
    final folder = await FolderRepository().create(name);

    if (folder != null) {
      _items.add(folder);
    }

    customNotifyListeners();
  }

  Future<void> remove(FolderModel folder) async {
    await FolderRepository().delete(folder);
    FolderRepository().prepareDir(currentFolder!);
    customNotifyListeners();
  }

  Future<void> removeImage(ImageModel image) async {
    await ImageRepository().delete(image);
    _currentImages?.remove(image);
    FolderRepository().prepareDir(currentFolder!);
    customNotifyListeners();
  }

  Future<void> moveFiles(List<ImageModel> images, FolderModel newFolder) async {
    for (ImageModel img in images) {
      var name = '${DateTime.now().millisecondsSinceEpoch}.gif';
      img.file.renameSync('${newFolder.path}/$name');
      _currentImages?.remove(img);
    }

    FolderRepository().prepareDir(currentFolder!);

    customNotifyListeners();
  }

  Future changeFolder(FolderModel? folder) async {
    init();

    _currentFolder = folder;

    _currentImages?.clear();

    if (folder != null) {
      _currentImages = await ImageRepository().list(folder);

      if (ImageConverter().converting?.folder.path == folder.path) {
        _currentImages?.add(ImageConverter().converting!);
      }

      for (QueueItem queueItem in ImageConverter().queue) {
        if (queueItem.imageModel.folder.path == folder.path) {
          _currentImages?.add(queueItem.imageModel);
        }
      }
    }
  }

  Future<void> convert(List<ImageModel> imgModels) async {
    if (_currentFolder == null) {
      return;
    }

    _converting = true;

    for (ImageModel img in imgModels) {
      _currentImages!.add(img);
    }

    customNotifyListeners();

    for (var mdl in imgModels) {
      _convertingList.add(mdl);

      await ImageConverter().convert(mdl, (ImageModel imageModel) {
        _convertingList.remove(imageModel);

        if (_convertingList.isEmpty) {
          _converting = false;
        }

        FolderRepository().prepareDir(currentFolder!);

        customNotifyListeners();
      });
    }
  }

  customNotifyListeners() {
    if(!_isDisposed){
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _isDisposed = true;
  }
}
