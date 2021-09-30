import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webp_to_gif/loader.dart';
import 'package:webp_to_gif/providers/selection_mode_provider.dart';

import 'models/image_model.dart';

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
            child: image.file == null ? const Loader() : Image.file(image.file!),
            onLongPress: () {
              selectionModeProvider.toggleSelection(image);
            },
            onPressed: () {
              if (image.file == null) {
                return;
              }

              if (selectionModeProvider.inSelectionMode ) {
                selectionModeProvider.toggleSelection(image);
                return;
              }

              Share.shareFiles([image.file!.path]);
            },
          ),
          IgnorePointer(
            child: Container(
              padding: const EdgeInsets.all(8),
              color: isSelected ? Colors.blue.withAlpha(100) : Colors.transparent,
              alignment: Alignment.bottomRight,
              child: !isSelected
                  ? Container()
                  : const Icon(
                Icons.check_box,
                size: 30,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
