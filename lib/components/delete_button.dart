import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? color;

  const DeleteButton({
    Key? key,
    required this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.delete),
    onPressed: onPressed,
  );
}
