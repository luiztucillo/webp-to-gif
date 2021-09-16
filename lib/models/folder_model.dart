import 'dart:io';

import 'package:flutter/material.dart';

class FolderModel {
  final String name;
  final Color color;
  final List<File> images = [];

  int? id;

  FolderModel(this.id, this.name, this.color);

  void addImage(File file) {
    images.add(file);
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
      map['id'],
      map['name'],
      Color(int.parse(map['color'])),
    );
  }
}
