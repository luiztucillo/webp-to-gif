import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:webp_to_gif/models/folder_model.dart';
import 'package:webp_to_gif/services/folders_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../image_container.dart';
import '../image_converter.dart';

class FoldersPage extends StatelessWidget {
  final FolderModel folder;

  const FoldersPage({Key? key, required this.folder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => FoldersService(currentFolder: folder),
      child: Consumer<FoldersService>(
        builder: (BuildContext context, FoldersService folderService,
            Widget? child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(folder.name),
            ),
            body: Column(
              children: [
                folder.images.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Colors.blue[300],
                            padding: const EdgeInsets.all(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.share, size: 30),
                              SizedBox(width: 16),
                              Text(
                                'Compartilhar todos',
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                          onPressed: () {
                            List<String> images = [];
                            for (File f in folder.images) {
                              images.add(f.path);
                            }
                            Share.shareFiles(images);
                          },
                        ),
                      )
                    : Container(),
                Expanded(
                  child: Center(
                    child: GridView.count(
                      crossAxisCount: 3,
                      children: folder.images
                          .map((File file) => ImageContainer(file: file))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: folderService.loading
                  ? null
                  : () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['webp'],
                        allowMultiple: true,
                      );

                      if (result != null) {
                        folderService.setLoading(true);

                        var converter = ImageConverter(
                          filePaths: result.paths.whereType<String>().toList(),
                        );

                        try {
                          await converter.convert(folderService);
                        } catch (e) {
                          //
                        }

                        folderService.setLoading(false);
                      }
                    },
              child: folderService.loading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Icon(Icons.add),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          );
        },
      ),
    );
  }
}
