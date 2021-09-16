import 'package:flutter/material.dart';
import 'package:webp_to_gif/models/image_model.dart';

class SelectionModeProvider extends ChangeNotifier {

  final List<ImageModel> _selectedItems = [];

  bool _inSelectionMode = false;

  bool get inSelectionMode => _inSelectionMode;

  List<ImageModel> get selectedItems => _selectedItems;

  void toggleSelection(ImageModel image) {
    if (image.isSelected()) {
      _removeFromSelection(image);
    } else {
      _addToSelection(image);
    }

    image.toggleSelect();
  }

  void _addToSelection(ImageModel image) {
    _selectedItems.add(image);
    _inSelectionMode = _selectedItems.isNotEmpty;
    notifyListeners();
  }

  void _removeFromSelection(ImageModel image) {
    _selectedItems.remove(image);
    _inSelectionMode = _selectedItems.isNotEmpty;
    notifyListeners();
  }
}
