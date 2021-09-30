import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:webp_to_gif/components/delete_button.dart';
import 'package:webp_to_gif/components/share_button.dart';
import 'package:webp_to_gif/models/folder_model.dart';
import 'package:webp_to_gif/models/image_model.dart';
import 'package:webp_to_gif/providers/folders_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webp_to_gif/providers/selection_mode_provider.dart';

import '../components/image_container.dart';
import '../services/image_converter.dart';

class FoldersPage extends StatelessWidget {
  final FolderModel folder;

  const FoldersPage({Key? key, required this.folder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => FoldersProvider(currentFolder: folder)),
        ChangeNotifierProvider(create: (context) => SelectionModeProvider()),
      ],
      child: Consumer<FoldersProvider>(
        builder: (context, folderProvider, child) =>
            Consumer<SelectionModeProvider>(
          builder: (context, selectionModeProvider, child) => Scaffold(
            appBar: AppBar(
              title: Text(folder.name),
            ),
            body: Center(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                children: folder.images
                    .map(
                      (ImageModel image) => Container(
                        color: Colors.grey[200],
                        child: ImageContainer(
                          key: Key(image.id != null ? image.id.toString() : const Uuid().toString()),
                          image: image,
                          isSelected: image.isSelected(),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _floatingButtons(folderProvider, selectionModeProvider),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          ),
        ),
      ),
    );
  }

  List<Widget> _floatingButtons(FoldersProvider folderProvider, SelectionModeProvider selectionModeProvider) {
    List<Widget> bts = [];

    if (folder.images.isNotEmpty && !selectionModeProvider.inSelectionMode) {
      bts.add(ShareButton(
        key: const Key('delete-all'),
        label: 'Compartilhar tudo',
        files: folder.images
            .map((ImageModel img) => img.file)
            .toList(),
      ));
    }

    if (selectionModeProvider.inSelectionMode && selectionModeProvider.selectedItems.isNotEmpty) {
      bts.add(ShareButton(
        key: const Key('share-selected'),
        color: Colors.green[300],
        label: 'Compartilhar',
        files: selectionModeProvider.selectedItems
            .map((ImageModel img) => img.file)
            .toList(),
      ));
    }

    if (selectionModeProvider.inSelectionMode && selectionModeProvider.selectedItems.isNotEmpty) {
      bts.add(DeleteButton(
        key: const Key('delete-button'),
        onPressed: () {
          for (ImageModel imgModel
          in selectionModeProvider.selectedItems) {
            folderProvider.removeImage(imgModel);
          }
        },
      ));
    }

    bts.add(FloatingActionButton(
      key: const Key('pick-files'),
      onPressed: () async {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['webp'],
          allowMultiple: true,
        );

        if (result != null) {
          List<ImageModel> imgModels = [];

          for (var path in result.paths) {
            var mdl = ImageModel(
              folderId: folder.id!,
              file: File(path!),
              converted: false,
            );

            imgModels.add(mdl);

            folderProvider.addImage(mdl);
          }

          for (var mdl in imgModels) {
            await ImageConverter(
              imgModel: mdl,
              folderProvider: folderProvider,
            ).convert();
          }
        }
      },
      child: const Icon(Icons.add),
    ));

    return bts;
  }
}
