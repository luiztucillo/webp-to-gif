import 'package:flutter/material.dart';
import 'package:webp_to_gif/models/image_model.dart';

class SelectionModeProvider extends ChangeNotifier {

  final List<ImageModel> _selectedItems = [];

  bool get inSelectionMode => _selectedItems.isNotEmpty;

  List<ImageModel> get selectedItems => _selectedItems;

  void toggleSelection(ImageModel image) {
    if (image.isSelected()) {
      _removeFromSelection(image);
    } else {
      _addToSelection(image);
    }

    image.toggleSelect();
  }

  void removeSelected() {
    _selectedItems.clear();
    notifyListeners();
  }

  void _addToSelection(ImageModel image) {
    _selectedItems.add(image);
    notifyListeners();
  }

  void _removeFromSelection(ImageModel image) {
    _selectedItems.remove(image);
    notifyListeners();
  }
}
