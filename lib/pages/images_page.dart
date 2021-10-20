import 'dart:io';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webp_to_gif/components/app_dialogs.dart';
import 'package:webp_to_gif/components/layout.dart';
import 'package:webp_to_gif/helpers/type.dart';
import 'package:webp_to_gif/models/folder_model.dart';
import 'package:webp_to_gif/models/image_model.dart';
import 'package:webp_to_gif/models/image_types/gif.dart';
import 'package:webp_to_gif/models/image_types/image_type.dart';
import 'package:webp_to_gif/models/image_types/jpg.dart';
import 'package:webp_to_gif/models/image_types/mp4.dart';
import 'package:webp_to_gif/models/image_types/png.dart';
import 'package:webp_to_gif/models/image_types/webp.dart';
import 'package:webp_to_gif/providers/ads_provider.dart';
import 'package:webp_to_gif/providers/folders_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webp_to_gif/providers/selection_mode_provider.dart';
import 'package:webp_to_gif/providers/share_provider.dart';
import 'package:webp_to_gif/services/ads.dart';

import '../components/image_container.dart';

class ImagesPage extends StatefulWidget {
  final FolderModel folder;
  final List<SharedMediaFile>? shared;

  const ImagesPage({
    Key? key,
    required this.folder,
    this.shared,
  }) : super(key: key);

  @override
  State<ImagesPage> createState() => _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage> {
  int grid = 3;

  AdsProvider? _adsProvider;
  Ads? ads;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _init();
    });
  }

  _init() async {
    var folderProvider = context.read<FoldersProvider>();

    _adsProvider = context.read<AdsProvider>();

    if (_adsProvider?.showAds == true) {
      _initAds();
    }

    await folderProvider.changeFolder(widget.folder);

    setState(() {});

    if (widget.shared != null) {
      _convertShared(widget.shared!, folderProvider);
    }
  }

  _initAds() {
    ads = Ads();
    if (Platform.isAndroid || Platform.isIOS) {
      ads!.loadConvertingAd();

      ads!.loadGridAd(() {
        setState(() {});
      });
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
    return ChangeNotifierProvider(
      create: (context) => SelectionModeProvider(),
      child: Consumer4<FoldersProvider, SelectionModeProvider, ShareProvider,
          AdsProvider>(
        builder: (
          context,
          folderProvider,
          selectionModeProvider,
          shareProvider,
          adsProvider,
          child,
        ) {
          if (folderProvider.currentFolder == null) {
            return Layout(
              title: widget.folder.name,
              subtitle: _subtitle(),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (shareProvider.sharedFiles != null) {
            return shareProvider.widget(
                onShare: (List<SharedMediaFile> files, FolderModel folder) {
              if (folder.path == folderProvider.currentFolder!.path) {
                _convertShared(files, folderProvider);
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ImagesPage(
                      folder: folder,
                      shared: files,
                    ),
                  ),
                );
              }
            });
          }

          if (folderProvider.currentImages == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Layout(
            title: widget.folder.name,
            subtitle: _subtitle(),
            body: Column(
              children: [
                !adsProvider.showAds
                    ? Container()
                    : Container(
                        color: Colors.grey.withAlpha(100),
                        child: SizedBox(
                          height: 100,
                          child: ads!.gridWidget(),
                        ),
                      ),
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.all(8),
                    crossAxisCount: grid,
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
                AnimatedSize(
                  child: SizedBox(
                    height: selectionModeProvider.inSelectionMode ? 60 : 0,
                    child: _actions(folderProvider, selectionModeProvider),
                  ),
                  duration: const Duration(milliseconds: 100),
                ),
              ],
            ),
            barActions: Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.grid_view),
                    onPressed: () async {
                      var size = await showOptionsDialog<int>(
                        context: context,
                        options: {
                          '2': 2,
                          '3': 3,
                          '4': 4,
                          '5': 5,
                        },
                        title: 'Tamanho do grid',
                      );

                      if (size == null) {
                        return;
                      }

                      setState(() {
                        grid = size;
                      });
                    }),
                _addButton(folderProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _actions(
    FoldersProvider folderProvider,
    SelectionModeProvider selectionModeProvider,
  ) {
    List<Widget> bts = [];

    if (selectionModeProvider.selectedItems.isNotEmpty) {
      bts.add(TextButton(
        child: const Icon(Icons.layers_clear_outlined),
        onPressed: () {
          for (var img in folderProvider.currentImages!) {
            img.unselect();
          }
          selectionModeProvider.removeSelected();
        },
      ));

      bts.add(TextButton(
        child: const Icon(Icons.share),
        onPressed: () {
          var files = selectionModeProvider.selectedItems
              .where((ImageModel img) => img.converted == true)
              .map((ImageModel img) => img.file)
              .toList();

          List<String> images = [];

          for (File file in files) {
            images.add(file.path);
          }

          Share.shareFiles(images);
        },
      ));

      bts.add(
        TextButton(
          child: const Icon(Icons.drive_file_move),
          onPressed: () async {
            var folder = await showOptionsDialog<FolderModel>(
              context: context,
              title: 'Para qual álbum deseja mover?',
              options: {
                for (var folder in folderProvider.list) folder.name: folder
              },
            );

            if (folder == null) {
              return;
            }

            folderProvider.moveFiles(
              selectionModeProvider.selectedItems,
              folder,
            );

            selectionModeProvider.removeSelected();
          },
        ),
      );

      bts.add(TextButton(
        child: const Icon(Icons.delete),
        onPressed: () {
          for (ImageModel imgModel in selectionModeProvider.selectedItems) {
            folderProvider.removeImage(imgModel);
          }

          selectionModeProvider.removeSelected();
        },
      ));
    }

    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: bts);
  }

  Widget _addButton(FoldersProvider folderProvider) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () async {
        final ImageType? type = await showOptionsDialog<ImageType>(
          context: context,
          title: 'Selecione o tipo dos arquivos que deseja importar',
          options: {
            'GIF': Gif(),
            'WEBP': Webp(),
            'MP4': Mp4(),
            'PNG': Png(),
            'JPG': Jpg(),
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

        if (_adsProvider?.showAds == true) {
          ads!.showConvertingAd();
        }

        folderProvider.convert(models);
      },
    );
  }

  _convertShared(List<SharedMediaFile> files, FoldersProvider folderProvider) {
    List<ImageModel> models = [];
    for (SharedMediaFile file in files) {
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

    if (_adsProvider?.showAds == true) {
      ads!.showConvertingAd();
      folderProvider.convert(models);
    }

    folderProvider.convert(models);
  }

  @override
  void dispose() {
    super.dispose();
    ads?.disposeAds();
  }
}
