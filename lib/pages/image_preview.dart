import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webp_to_gif/providers/folders_provider.dart';
import 'dart:ui' as ui;

import '../components/layout.dart';
import '../models/image_model.dart';
import 'image_crop.dart';
import 'image_resize.dart';

class ImagePreview extends StatelessWidget {
  final ImageModel imageModel;
  final ui.Image image;
  final String size;

  const ImagePreview({
    Key? key,
    required this.imageModel,
    required this.image,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Layout(
      body: Consumer<FoldersProvider>(
        builder: (context, foldersProvider, _) => Column(
          children: [
            Expanded(
              child: Container(
                height: image.height.toDouble(),
                color: const Color(0xfff0f0f0),
                child: Center(
                  child: Image.file(imageModel.file),
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('${image.width} x ${image.height}'),
                      Text(size),
                      TextButton(
                        child: const Icon(Icons.share),
                        onPressed: () {
                          Share.shareFiles([imageModel.file.path]);
                        },
                      ),
                      TextButton(
                        child: const Icon(Icons.delete),
                        onPressed: () {
                          foldersProvider.removeImage(imageModel);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: const Text('Resize'),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => ImageResize(
                            image: image,
                            imageModel: imageModel,
                            size: size,
                          ),
                        ));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
      title: '',
    );
  }
}
