import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareButton extends StatelessWidget {
  final String label;
  final List<File> files;
  final Color? color;

  const ShareButton({
    Key? key,
    required this.label,
    required this.files,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        child: TextButton(
          style: TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: color ?? Colors.blue[300],
            padding: const EdgeInsets.all(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.share, size: 30),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
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
