import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:webp_to_gif/components/app_dialogs.dart';
import 'package:webp_to_gif/helpers/type.dart';
import 'package:webp_to_gif/models/folder_model.dart';
import 'package:webp_to_gif/providers/folders_provider.dart';

import 'folders_page.dart';

class SharedPage extends StatelessWidget {
  final List<SharedMediaFile> files;
  final VoidCallback finishShare;

  const SharedPage({
    Key? key,
    required this.files,
    required this.finishShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recebendo compartilhamento'),
      ),
      body: ChangeNotifierProvider(
        create: (BuildContext context) => FoldersProvider(),
        child: Consumer<FoldersProvider>(
          builder: (context, FoldersProvider folderProvider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        child: const Text('Importar e Converter'),
                        onPressed: () async {
                          var folder = await showOptionsDialog<FolderModel>(
                            context: context,
                            title: 'Selecione a pasta para importar',
                            options: {
                              for (var folder in folderProvider.list)
                                folder.name: folder
                            },
                          );

                          if (folder == null) {
                            return;
                          }

                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FoldersPage(
                                folder: folder,
                                shared: files,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    TextButton(
                      child: const Text('Cancelar'),
                      onPressed: finishShare,
                    ),
                  ],
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    children: files.map((SharedMediaFile file) {
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(
                                  File(file.thumbnail ?? file.path),
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          IgnorePointer(
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  Type.getType(file.path)
                                      .extension()
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                                color: Colors.black.withAlpha(150),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
