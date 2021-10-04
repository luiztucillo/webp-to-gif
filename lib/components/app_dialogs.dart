import 'package:flutter/material.dart';

showInputDialog({
  required BuildContext context,
  required String title,
  required Function(String) onSubmitted,
  String? helperText,
  String intialValue = '',
}) {
  final _controller = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                helperText: helperText ?? '',
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    onSubmitted(_controller.text);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Future<T?> showOptionsDialog<T>({
  required BuildContext context,
  required Map<String, T> options,
  required String title,
}) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: options.entries.map((entry) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(entry.key),
                ),
                onPressed: () {
                  Navigator.pop(context, entry.value);
                },
              ),
            );
          }).toList(),
        ),
      );
    },
  );
}
