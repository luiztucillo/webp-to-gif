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
    return Card(
      child: ListTile(
        onTap: onPressed,
        leading: const Icon(Icons.folder),
        title: Text(folder.name),
        trailing: TextButton(
          child: const Icon(Icons.delete),
          onPressed: onDeletePressed,
        ),
      ),
    );
  }
}
