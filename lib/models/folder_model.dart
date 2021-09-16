import 'package:flutter/material.dart';

import 'image_model.dart';

class FolderModel {
  final String name;
  final Color color;
  final List<ImageModel> images = [];

  int? id;

  FolderModel({this.id, required this.name, required this.color});

  void resetImages() {
    images.clear();
  }

  void addImage(ImageModel image) {
    images.add(image);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'name': name,
      'color': color.value,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory FolderModel.fromMap(Map<String, dynamic> map) {
    return FolderModel(
      id: map['id'],
      name: map['name'],
      color: Color(int.parse(map['color'])),
    );
  }
}
