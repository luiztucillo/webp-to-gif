import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webp_to_gif/providers/folders_provider.dart';
import 'dart:ui' as ui;

import '../components/layout.dart';
import '../models/image_model.dart';

class ImageCrop extends StatefulWidget {
  final ImageModel imageModel;
  final ui.Image image;
  final String size;

  const ImageCrop({
    Key? key,
    required this.imageModel,
    required this.image,
    required this.size,
  }) : super(key: key);

  @override
  State<ImageCrop> createState() => _ImageCropState();
}

class _ImageCropState extends State<ImageCrop> {
  @override
  Widget build(BuildContext context) {
    return Layout(
      body: Consumer<FoldersProvider>(
        builder: (context, foldersProvider, _) => Column(
          children: [
            Expanded(
              child: Container(
                height: widget.image.height.toDouble(),
                color: const Color(0xfff0f0f0),
                child: Center(
                  child: Image.file(widget.imageModel.file),
                ),
              ),
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
      title: '',
    );
  }
}
