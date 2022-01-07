import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webp_to_gif/components/dialog.dart';
import 'package:webp_to_gif/components/image_container/edit_area.dart';
import 'package:webp_to_gif/models/image_model.dart';
import 'package:webp_to_gif/providers/folders_provider.dart';
import 'dart:ui' as ui;

imageContainerDialog(BuildContext context, ImageModel image, FoldersProvider foldersProvider) async {
  var file = image.file.readAsBytesSync();
  var size = double.parse(file.lengthInBytes.toString());
  ui.Image img = await decodeImageFromList(file);
  var unit = 'bs';

  if (size > 1024) {
    size = (size / 1024).roundToDouble();
    unit = 'Kbs';
  }

  if (size > 1024) {
    size = (size / 1024).roundToDouble();
    unit = 'Mbs';
  }

  if (size > 1024) {
    size = (size / 1024).roundToDouble();
    unit = 'Gbs';
  }

  showCustomDialog(
    context,
    ImageContainer(
      imageModel: image,
      image: img,
      size: '$size $unit',
    ),
  );
}

class ImageContainer extends StatefulWidget {
  final ImageModel imageModel;
  final ui.Image image;
  final String size;

  const ImageContainer({
    Key? key,
    required this.imageModel,
    required this.image,
    required this.size,
  }) : super(key: key);

  @override
  _ImageContainerState createState() => _ImageContainerState();
}

class _ImageContainerState extends State<ImageContainer> {
  int _previewWidth = 0;

  @override
  void initState() {
    super.initState();
    _previewWidth = widget.image.width;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FoldersProvider>(
      builder: (_, foldersProvider, __) => Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                height: widget.image.height.toDouble(),
                color: const Color(0xfff0f0f0),
                child: Center(
                  child: SizedBox(
                    width: _previewWidth.toDouble(),
                    height: (widget.image.height / widget.image.width) * _previewWidth.round(),
                    child: Image.file(widget.imageModel.file),
                  ),
                ),
              ),
            ),
            Stack(
              children: [
                TextButton(
                  child: const Icon(Icons.arrow_back_rounded),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${widget.image.width} x ${widget.image.height}'),
                      const SizedBox(width: 50),
                      Text(widget.size),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  child: TextButton(
                    child: const Icon(Icons.share),
                    onPressed: () {
                      Share.shareFiles([widget.imageModel.file.path]);
                    },
                  ),
                ),
              ],
            ),
            EditArea(
              imgModel: widget.imageModel,
              img: widget.image,
              onResize: (width) {
                setState(() {
                  _previewWidth = width;
                });
              },
              onSave: (width, height, frameRate) {
                foldersProvider.resize(widget.imageModel, width, height, frameRate);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
