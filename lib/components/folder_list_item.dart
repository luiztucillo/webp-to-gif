import 'package:flutter/material.dart';
import 'package:webp_to_gif/models/folder_model.dart';

class FolderListItem extends StatelessWidget {
  final FolderModel folder;
  final VoidCallback onPressed;
  final Function(BuildContext)? onLongPress;

  const FolderListItem({
    Key? key,
    required this.folder,
    required this.onPressed,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _cover()),
          Text(folder.name, style: Theme.of(context).textTheme.bodyText2),
        ],
      ),
      onTap: onPressed,
      onLongPress: () {
        if (onLongPress != null) {
          onLongPress!(context);
        }
      },
    );
  }

  Widget _cover({Widget? child}) {
    if (folder.cover == null) {
      return Container(
        child: child ??
            const Center(
              child: Icon(
                Icons.folder,
                color: Colors.grey,
              ),
            ),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
      );
    }

    return Container(
      child: child ?? Container(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: FileImage(folder.cover!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
