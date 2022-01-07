import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webp_to_gif/components/image_container/dialog.dart';
import 'package:webp_to_gif/providers/folders_provider.dart';
import 'package:webp_to_gif/providers/selection_mode_provider.dart';

import '../models/image_model.dart';

class ImageContainer extends StatelessWidget {
  final ImageModel image;
  final bool isSelected;
  final VoidCallback onDelete;

  const ImageContainer({
    Key? key,
    required this.image,
    required this.isSelected,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<SelectionModeProvider, FoldersProvider>(
      builder: (context, selectionModeProvider, foldersProvider, widget) => Stack(
        children: [
          Opacity(
            opacity: image.converted ? 1 : 0.2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(image.thumbnail ?? image.file),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          TextButton(
            child: Container(),
            onLongPress: () {
              if (!image.converted) {
                return;
              }

              selectionModeProvider.toggleSelection(image);
            },
            onPressed: () async {
              if (!image.converted) {
                return;
              }

              if (selectionModeProvider.inSelectionMode) {
                selectionModeProvider.toggleSelection(image);
                return;
              }

              imageContainerDialog(context, image, foldersProvider);
            },
          ),
          image.converted
              ? const IgnorePointer()
              : const IgnorePointer(
                  child: Center(child: CircularProgressIndicator()),
                ),
          !isSelected
              ? Container()
              : IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent, width: 3),
                    ),
                    alignment: Alignment.bottomRight,
                    child: const Icon(
                      Icons.check,
                      size: 30,
                      color: Colors.blue,
                    ),
                  ),
                ),
          IgnorePointer(
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.all(5),
                child: Text(
                  image.imageType.extension().toUpperCase(),
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                color: Colors.black.withAlpha(150),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
