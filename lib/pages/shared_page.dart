import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:webp_to_gif/components/app_dialogs.dart';
import 'package:webp_to_gif/components/layout.dart';
import 'package:webp_to_gif/helpers/type.dart';
import 'package:webp_to_gif/models/folder_model.dart';
import 'package:webp_to_gif/providers/folders_provider.dart';
import 'package:webp_to_gif/providers/share_provider.dart';

class SharedPage extends StatelessWidget {
  final Function(List<SharedMediaFile>, FolderModel) onShare;

  const SharedPage({
    Key? key,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ShareProvider shareProvider, child) => Layout(
        title: 'Compartilhamento',
        subtitle: shareProvider.sharedFiles!.length == 1 ? '1 arquivo compartilhado' : '${shareProvider.sharedFiles!.length} arquivos compartilhados',
        showLeading: false,
        body: ChangeNotifierProvider(
          create: (BuildContext context) => FoldersProvider(),
          child: Consumer<FoldersProvider>(
            builder: (context, FoldersProvider folderProvider, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
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

                              var files = shareProvider.sharedFiles!;

                              shareProvider.finishShare();

                              onShare(files, folder);
                            },
                          ),
                        ),
                        TextButton(
                          child: const Text('Cancelar'),
                          onPressed: shareProvider.finishShare,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.count(
                      padding: const EdgeInsets.all(8),
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: shareProvider.sharedFiles!.map((SharedMediaFile file) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }
}
