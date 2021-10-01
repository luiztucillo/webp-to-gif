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
          Container(
            decoration: ShapeDecoration(
              color:
      isSelected ? Colors.blue.withAlpha(50) : Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          Opacity(
            opacity: image.converted ? 1 : 0.3,
            child: TextButton(
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

                if (selectionModeProvider.inSelectionMode) {
                  selectionModeProvider.toggleSelection(image);
                  return;
                }

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      contentPadding: const EdgeInsets.all(0),
                      content: Image.file(image.file),
                    );
                  },
                );
              },
            ),
          ),
          image.converted
              ? const IgnorePointer()
              : const IgnorePointer(
                  child: LinearProgressIndicator(),
                ),
          IgnorePointer(
            child: Container(
              padding: const EdgeInsets.all(8),
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
