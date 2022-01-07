import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webp_to_gif/models/image_model.dart';
import 'package:webp_to_gif/providers/folders_provider.dart';
import 'dart:ui' as ui;

class EditArea extends StatefulWidget {
  final ImageModel imgModel;
  final ui.Image img;
  final void Function(int) onResize;
  final void Function(int, int, int) onSave;

  const EditArea({
    Key? key,
    required this.imgModel,
    required this.img,
    required this.onSave,
    required this.onResize,
  }) : super(key: key);

  @override
  _EditAreaState createState() => _EditAreaState();
}

class _EditAreaState extends State<EditArea> {
  double _sliderWidth = 0;
  double _sliderHeight = 0;

  @override
  void initState() {
    super.initState();
    _sliderWidth = widget.img.width.toDouble();
    _sliderHeight = (widget.img.height / widget.img.width) * _sliderWidth.round();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FoldersProvider>(
      builder: (context, foldersProvider, _) => Column(
        children: [
          Text(
            'Tamanho',
            style: Theme.of(context).textTheme.headline5,
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text('${_sliderWidth.round().toString()} x ${_sliderHeight.round().toString()}'),
              ),
              Expanded(
                child: Slider(
                  max: widget.img.width.toDouble(),
                  min: 10,
                  value: _sliderWidth,
                  label: _sliderWidth.round().toString(),
                  onChanged: (double newValue) {
                    setState(() {
                      _sliderWidth = newValue;
                      _sliderHeight = (widget.img.height / widget.img.width) * _sliderWidth.round();
                      widget.onResize(_sliderWidth.round());
                    });
                  },
                ),
              ),
            ],
          ),
          ElevatedButton(
            child: const Text('Salvar'),
            onPressed: () {
              widget.onSave(_sliderWidth.round(), _sliderHeight.round(), 10);
            },
          ),
        ],
      ),
    );
  }
}
