import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const DeleteButton({
    Key? key,
    required this.onPressed,
    this.label = 'Excluir',
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(8),
        child: FloatingActionButton(
          backgroundColor: Colors.red,
          child: const Icon(Icons.delete),
          onPressed: onPressed,
        ),
      );
}
