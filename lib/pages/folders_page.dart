import 'dart:io';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:webp_to_gif/components/app_dialogs.dart';
import 'package:webp_to_gif/components/delete_button.dart';
import 'package:webp_to_gif/components/layout.dart';
import 'package:webp_to_gif/components/share_button.dart';
import 'package:webp_to_gif/helpers/type.dart';
import 'package:webp_to_gif/models/folder_model.dart';
import 'package:webp_to_gif/models/image_model.dart';
import 'package:webp_to_gif/models/image_types/gif.dart';
import 'package:webp_to_gif/models/image_types/image_type.dart';
import 'package:webp_to_gif/models/image_types/mp4.dart';
import 'package:webp_to_gif/models/image_types/webp.dart';
import 'package:webp_to_gif/pages/shared_page.dart';
import 'package:webp_to_gif/providers/folders_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webp_to_gif/providers/selection_mode_provider.dart';
import 'package:webp_to_gif/providers/share_provider.dart';
import 'package:webp_to_gif/services/ads.dart';

import '../components/image_container.dart';

class FoldersPage extends StatefulWidget {
  final FolderModel folder;
  final List<SharedMediaFile>? shared;

  const FoldersPage({
    Key? key,
    required this.folder,
    this.shared,
  }) : super(key: key);

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  FoldersProvider? _folderProvider;
  Ads ads = Ads();

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid || Platform.isIOS) {
      ads.loadConvertingAd();

      WidgetsBinding.instance?.addPostFrameCallback((_) {
        ads.loadGridAd(() {
          setState(() {});
        });
      });
    }

    _init();
  }

  _init() async {
    _folderProvider = FoldersProvider();

    await _folderProvider!.changeFolder(widget.folder);

    setState(() {});

    if (widget.shared != null) {
      _convertShared(_folderProvider!);
    }
  }

  String _subtitle() {
    if (widget.folder.filesCount == null || widget.folder.filesCount == 0) {
      return 'Nenhum arquivo';
    }

    if (widget.folder.filesCount == 1) {
      return '1 arquivo';
    }

    return '${widget.folder.filesCount} arquivos';
  }

  @override
  Widget build(BuildContext context) {
    if (_folderProvider == null) {
      return Layout(
        title: widget.folder.name,
        subtitle: _subtitle(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (BuildContext context) => _folderProvider),
        ChangeNotifierProvider(create: (context) => SelectionModeProvider()),
        ChangeNotifierProvider(create: (context) => ShareProvider()),
      ],
      child: Consumer3<FoldersProvider, SelectionModeProvider, ShareProvider>(
        builder: (context, folderProvider, selectionModeProvider, shareProvider, child) {
          if (shareProvider.sharedFiles != null) {
            return shareProvider.widget();
          }

          if (folderProvider.currentImages == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Layout(
            title: widget.folder.name,
            subtitle: _subtitle(),
            body: Column(
              children: [
                Container(
                  color: Colors.grey.withAlpha(100),
                  child: SizedBox(
                    height: 100,
                    child: ads.gridWidget(),
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.all(8),
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: folderProvider.currentImages!
                        .map((ImageModel image) => ImageContainer(
                      image: image,
                      isSelected: image.isSelected(),
                      onDelete: () {
                        folderProvider.removeImage(image);
                      },
                    ))
                        .toList(),
                  ),
                ),
              ],
            ),
            barActions: _barActions(folderProvider, selectionModeProvider),
          );
        },
      ),
    );
  }

  Widget _barActions(
    FoldersProvider folderProvider,
    SelectionModeProvider selectionModeProvider,
  ) {
    List<Widget> bts = [];

    if (folderProvider.currentImages!.isNotEmpty &&
        selectionModeProvider.inSelectionMode) {
      bts.add(ShareButton(
        files: folderProvider.currentImages!
            .where((ImageModel img) => img.converted == true)
            .map((ImageModel img) => img.file)
            .toList(),
      ));
    }

    if (folderProvider.currentImages!.isNotEmpty &&
        selectionModeProvider.inSelectionMode &&
        selectionModeProvider.selectedItems.isNotEmpty) {
      bts.add(IconButton(
        icon: const Icon(Icons.drive_file_move),
        onPressed: () async {
          var folder = await showOptionsDialog<FolderModel>(
            context: context,
            title: 'Selecione a pasta para importar',
            options: {
              for (var folder in folderProvider.list) folder.name: folder
            },
          );

          if (folder == null) {
            return;
          }

          folderProvider.moveFiles(selectionModeProvider.selectedItems, folder);

          selectionModeProvider.removeSelected();
        },
      ));
    }

    if (folderProvider.currentImages!.isNotEmpty &&
        selectionModeProvider.inSelectionMode &&
        selectionModeProvider.selectedItems.isNotEmpty) {
      bts.add(DeleteButton(
        onPressed: () {
          for (ImageModel imgModel in selectionModeProvider.selectedItems) {
            folderProvider.removeImage(imgModel);
          }

          selectionModeProvider.removeSelected();
        },
      ));
    }

    if (!selectionModeProvider.inSelectionMode) {
      bts.add(IconButton(
        icon: const Icon(Icons.add),
        onPressed: () async {
          final ImageType? type = await showOptionsDialog<ImageType>(
            context: context,
            title: 'Selecione o tipo dos arquivos que deseja importar',
            options: {
              'GIF': Gif(),
              'WEBP': Webp(),
              'MP4': Mp4(),
              // 'PNG': Png(),
              // 'JPG': Jpg(),
            },
          );

          if (type == null) {
            return;
          }

          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: [type.extension()],
            allowMultiple: true,
          );

          if (result == null) {
            return;
          }

          List<ImageModel> models = [];
          for (String path in result.paths.whereType<String>().toList()) {
            var mdl = ImageModel(
              folder: folderProvider.currentFolder!,
              file: File(path),
              converted: false,
              imageType: type,
            );

            models.add(mdl);
          }

          ads.showConvertingAd();
          folderProvider.convert(models);
        },
      ));
    }

    return Row(mainAxisAlignment: MainAxisAlignment.end, children: bts);
  }

  _convertShared(FoldersProvider folderProvider) {
    List<ImageModel> models = [];
    for (SharedMediaFile file in widget.shared!) {
      var mdl = ImageModel(
        folder: folderProvider.currentFolder!,
        file: File(file.path),
        converted: false,
        imageType: Type.getType(file.path),
        thumbnail:
            file.thumbnail != null ? File(file.thumbnail!) : File(file.path),
      );

      models.add(mdl);
    }

    ads.showConvertingAd();
    folderProvider.convert(models);
  }

  @override
  void dispose() {
    super.dispose();
    ads.disposeAds();
  }
}
