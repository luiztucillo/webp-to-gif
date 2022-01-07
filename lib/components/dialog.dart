import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future showCustomDialog(BuildContext context, Widget content) async {
  showDialog(
    context: context,
    builder: (context) {
      return Material(
        color: Colors.transparent,
        child: content,
      );
    },
  );
}
