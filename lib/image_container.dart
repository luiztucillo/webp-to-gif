import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ImageContainer extends StatelessWidget {
  final File file;

  const ImageContainer({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Image.file(file),
      onPressed: () {
        Share.shareFiles([file.path]);
      },
    );
  }
}
