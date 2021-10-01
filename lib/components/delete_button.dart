import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  final String heroTag;
  final VoidCallback onPressed;
  final Color? color;

  const DeleteButton({
    Key? key,
    required this.onPressed,
    required this.heroTag,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(8),
        child: FloatingActionButton(
          heroTag: heroTag,
          backgroundColor: Colors.red,
          child: const Icon(Icons.delete),
          onPressed: onPressed,
        ),
      );
}
