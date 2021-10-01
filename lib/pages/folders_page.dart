import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webp_to_gif/components/delete_button.dart';
import 'package:webp_to_gif/components/share_button.dart';
import 'package:webp_to_gif/models/folder_model.dart';
import 'package:webp_to_gif/models/image_model.dart';
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
                  leading: IconButton(
                    icon: const Icon(Icons.navigate_before),
                    onPressed: () {
                      if (folderProvider.converting) {
                        const snackBar = SnackBar(
                            content: Text(
                                'Você não pode voltar até terminar de converter as imagens'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        return;
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                body: Column(
                  children: [
                    ads.gridAd != null
                        ? SizedBox(
                            height: 100,
                            child: AdWidget(ad: ads.gridAd),
                          )
                        : Container(),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                        children: folderProvider.currentImages!
                            .map((ImageModel image) => ImageContainer(
                                  image: image,
                                  isSelected: image.isSelected(),
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
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['webp'],
          allowMultiple: true,
        );

        if (result == null) {
          return;
        }

        ads.showConvertingAd();
        folderProvider.convert(result.paths.whereType<String>().toList());
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
