import 'package:flutter/material.dart';
import 'package:webp_to_gif/models/folder_model.dart';

class FolderListItem extends StatelessWidget {
  final FolderModel folder;
  final VoidCallback onPressed;
  final VoidCallback onDeletePressed;

  const FolderListItem({
    Key? key,
    required this.folder,
    required this.onPressed,
    required this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key(folder.path),
      padding: const EdgeInsets.all(8),
      child: TextButton(
        style: TextButton.styleFrom(backgroundColor: Colors.blue[50]),
        onPressed: onPressed,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.folder, size: 30),
            const SizedBox(width: 16),
            Text(
              folder.name,
              style: const TextStyle(fontSize: 16),
            ),
            Expanded(child: Container()),
            TextButton(
              onPressed: onDeletePressed,
              child: const Icon(Icons.delete, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
