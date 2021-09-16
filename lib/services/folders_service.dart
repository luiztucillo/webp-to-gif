import 'dart:io';

import 'package:webp_to_gif/models/folder_model.dart';
import 'package:flutter/material.dart';
import 'package:webp_to_gif/repositories/folder_repository.dart';

class FoldersService extends ChangeNotifier {
  final List<FolderModel> _items = [];
  bool loading = false;
  FolderModel? currentFolder;

  FoldersService({this.currentFolder}) {
    init();
  }

  init() async {
    _items.addAll(await FolderRepository().list());
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
        for (File fl in folder.images) {
          fl.delete();
        }
        _items.remove(fdr);
        break;
      }
    }
    notifyListeners();
  }

  void removeAll() {
    _items.clear();
    notifyListeners();
  }

  void addImage(File file) {
    currentFolder?.addImage(file);
    notifyListeners();
  }
}
