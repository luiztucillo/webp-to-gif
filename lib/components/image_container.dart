import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webp_to_gif/providers/selection_mode_provider.dart';

import '../models/image_model.dart';

class ImageContainer extends StatelessWidget {
  final ImageModel image;
  final bool isSelected;

  const ImageContainer({
    Key? key,
    required this.image,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectionModeProvider>(
      builder: (context, selectionModeProvider, widget) => Stack(
        children: [
          TextButton(
            child: Center(
              child: Image.file(image.file),
            ),
            onLongPress: () {
              if (!image.converted) {
                return;
              }

              selectionModeProvider.toggleSelection(image);
            },
            onPressed: () {
              if (!image.converted) {
                return;
              }

              if (selectionModeProvider.inSelectionMode ) {
                selectionModeProvider.toggleSelection(image);
                return;
              }

              Share.shareFiles([image.file.path]);
            },
          ),
          image.converted ? const IgnorePointer() : const IgnorePointer(
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 8,
                color: Colors.white,
                backgroundColor: Colors.blue,
              ),
            ),
          ),
          IgnorePointer(
            child: Container(
              padding: const EdgeInsets.all(8),
              color: isSelected ? Colors.blue.withAlpha(50) : Colors.transparent,
              alignment: Alignment.bottomRight,
              child: !isSelected
                  ? Container()
                  : const Icon(
                Icons.check_box,
                size: 30,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
