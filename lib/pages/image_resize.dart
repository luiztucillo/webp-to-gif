import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webp_to_gif/providers/folders_provider.dart';
import 'dart:ui' as ui;

import '../components/layout.dart';
import '../models/image_model.dart';

class ImageResize extends StatefulWidget {
  final ImageModel imageModel;
  final ui.Image image;
  final String size;

  const ImageResize({
    Key? key,
    required this.imageModel,
    required this.image,
    required this.size,
  }) : super(key: key);

  @override
  State<ImageResize> createState() => _ImageResizeState();
}

class _ImageResizeState extends State<ImageResize> {
  int _previewWidth = 0;
  double _sliderWidth = 0;
  double _sliderHeight = 0;

  @override
  void initState() {
    super.initState();
    _previewWidth = widget.image.width;
    _sliderWidth = widget.image.width.toDouble();
    _sliderHeight = (widget.image.height / widget.image.width) * _sliderWidth.round();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      body: Consumer<FoldersProvider>(
        builder: (context, foldersProvider, _) => Column(
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
            Column(
              children: [
                Text('${_sliderWidth.round().toString()} x ${_sliderHeight.round().toString()}'),
                Slider(
                  max: widget.image.width.toDouble(),
                  min: 10,
                  value: _sliderWidth,
                  label: _sliderWidth.round().toString(),
                  onChanged: (double newValue) {
                    setState(() {
                      _sliderWidth = newValue;
                      _sliderHeight = (widget.image.height / widget.image.width) * _sliderWidth.round();
                      // widget.onResize(_sliderWidth.round());
                      setState(() {
                        _previewWidth = _sliderWidth.round();
                      });
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    foldersProvider.resize(widget.imageModel, _sliderWidth.round(), _sliderHeight.round(), 10);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
      title: '',
    );
  }
}
