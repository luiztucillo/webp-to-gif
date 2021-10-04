import 'dart:io';

import 'package:webp_to_gif/components/app_dialogs.dart';
import 'package:webp_to_gif/components/delete_button.dart';
import 'package:webp_to_gif/components/share_button.dart';
import 'package:webp_to_gif/models/folder_model.dart';
import 'package:webp_to_gif/models/image_model.dart';
import 'package:webp_to_gif/models/image_types/gif.dart';
import 'package:webp_to_gif/models/image_types/image_type.dart';
import 'package:webp_to_gif/models/image_types/webp.dart';
import 'package:webp_to_gif/providers/folders_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webp_to_gif/providers/selection_mode_provider.dart';
import 'package:webp_to_gif/services/ads.dart';

import '../components/image_container.dart';

class FoldersPage extends StatefulWidget {
  final FolderModel folder;

  const FoldersPage({Key? key, required this.folder}) : super(key: key);

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
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
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (BuildContext context) {
          return FoldersProvider(folder: widget.folder);
        }),
        ChangeNotifierProvider(create: (context) {
          return SelectionModeProvider();
        }),
      ],
      child: Consumer<FoldersProvider>(
        builder: (context, folderProvider, child) {
          if (folderProvider.currentImages == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Consumer<SelectionModeProvider>(
            builder: (BuildContext context, selectionModeProvider, child) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(widget.folder.name),
                ),
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
                        crossAxisCount: 3,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
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
                floatingActionButton: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:
                      _floatingButtons(folderProvider, selectionModeProvider),
                ), // This trailing comma makes auto-formatting nicer for build methods.
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _floatingButtons(
    FoldersProvider folderProvider,
    SelectionModeProvider selectionModeProvider,
  ) {
    List<Widget> bts = [];

    if (folderProvider.currentImages!.isNotEmpty &&
        !selectionModeProvider.inSelectionMode) {
      bts.add(ShareButton(
        heroTag: 'share-all',
        files: folderProvider.currentImages!
            .where((ImageModel img) => img.converted == true)
            .map((ImageModel img) => img.file)
            .toList(),
      ));
    }

    if (folderProvider.currentImages!.isNotEmpty &&
        selectionModeProvider.inSelectionMode &&
        selectionModeProvider.selectedItems.isNotEmpty) {
      bts.add(ShareButton(
        heroTag: 'share-selected',
        color: Colors.green[300],
        files: selectionModeProvider.selectedItems
            .map((ImageModel img) => img.file)
            .toList(),
      ));
    }

    if (folderProvider.currentImages!.isNotEmpty &&
        selectionModeProvider.inSelectionMode &&
        selectionModeProvider.selectedItems.isNotEmpty) {
      bts.add(DeleteButton(
        heroTag: 'delete-button',
        onPressed: () {
          for (ImageModel imgModel in selectionModeProvider.selectedItems) {
            folderProvider.removeImage(imgModel);
          }

          selectionModeProvider.removeSelected();
        },
      ));
    }

    bts.add(FloatingActionButton(
      heroTag: 'add-button',
      onPressed: () async {
        final ImageType? type = await showOptionsDialog<ImageType>(
          context: context,
          title: 'Selecione o tipo dos arquivos que deseja importar',
          options: {
            'GIF': Gif(),
            'WEBP': Webp(),
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
      child: const Icon(Icons.add),
    ));

    return bts;
  }

  @override
  void dispose() {
    super.dispose();
    ads.disposeAds();
  }
}
