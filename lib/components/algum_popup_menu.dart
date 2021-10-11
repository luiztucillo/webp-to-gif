import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AlbumPopupMenu {
  static Future showAlbumMenu({
    required BuildContext context,
  }) async {
    final RenderBox button = context.findRenderObject()! as RenderBox;

    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;

    final offset = Offset(button.size.width - 50, 16);

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(offset, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero) + offset,
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

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
