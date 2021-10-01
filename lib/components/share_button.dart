import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareButton extends StatelessWidget {
  final String heroTag;
  final List<File> files;
  final Color? color;

  const ShareButton({
    Key? key,
    required this.files,
    required this.heroTag,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(8),
        child: FloatingActionButton(
          heroTag: heroTag,
          backgroundColor: Colors.green,
          child: const Icon(Icons.share),
          onPressed: () {
            List<String> images = [];
            for (File file in files) {
              images.add(file.path);
            }
            Share.shareFiles(images);
          },
        ),
      );
}
