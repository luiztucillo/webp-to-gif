import 'package:webp_to_gif/components/share_button.dart';
import 'package:webp_to_gif/models/folder_model.dart';
import 'package:webp_to_gif/models/image_model.dart';
import 'package:webp_to_gif/providers/folders_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webp_to_gif/providers/selection_mode_provider.dart';

import '../image_container.dart';
import '../image_converter.dart';

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
            body: Column(
              children: [
                folder.images.isNotEmpty
                    ? ShareButton(
                        label: 'Compartilhar todos',
                        files: folder.images
                            .map((ImageModel img) => img.file)
                            .toList(),
                      )
                    : Container(),
                selectionModeProvider.inSelectionMode &&
                        selectionModeProvider.selectedItems.isNotEmpty
                    ? ShareButton(
                        color: Colors.green[300],
                        label: 'Compartilhar selecionadas',
                        files: selectionModeProvider.selectedItems
                            .map((ImageModel img) => img.file)
                            .toList(),
                      )
                    : Container(),
                Expanded(
                  child: Center(
                    child: GridView.count(
                      crossAxisCount: 3,
                      children: folder.images
                          .map(
                            (ImageModel image) => ImageContainer(
                              image: image,
                              isSelected: image.isSelected(),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: folderProvider.loading
                  ? null
                  : () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['webp'],
                        allowMultiple: true,
                      );

                      if (result != null) {
                        folderProvider.setLoading(true);

                        var converter = ImageConverter(
                          filePaths: result.paths.whereType<String>().toList(),
                        );

                        try {
                          await converter.convert(folderProvider);
                        } catch (e) {
                          //
                        }

                        folderProvider.setLoading(false);
                      }
                    },
              child: folderProvider.loading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Icon(Icons.add),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          ),
        ),
      ),
    );
  }
}
