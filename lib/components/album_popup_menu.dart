import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AlbumPopupMenu {
  static Future showAlbumMenu({
    required BuildContext context,
  }) async {
    return await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (BuildContext context) => SafeArea(
        bottom: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(1);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const <Widget>[
                    Icon(Icons.delete, size: 24),
                    SizedBox(width: 16),
                    Text('Excluir'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
