import 'package:webp_to_gif/components/algum_popup_menu.dart';
import 'package:webp_to_gif/components/app_dialogs.dart';
import 'package:webp_to_gif/components/folder_list_item.dart';
import 'package:webp_to_gif/components/layout.dart';
import 'package:webp_to_gif/models/folder_model.dart';
import 'package:webp_to_gif/providers/folders_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'folders_page.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => FoldersProvider(),
      child: Consumer<FoldersProvider>(
        builder: (BuildContext context, FoldersProvider folderProvider,
            Widget? child) {
          return Layout(
            title: 'Álbuns',
            subtitle: '${folderProvider.folderCount} álbuns',
            showLeading: false,
            barActions: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                showInputDialog(
                  context: context,
                  title: 'Criar álbum',
                  helperText: 'Nome do álbum',
                  onSubmitted: (String value) {
                    folderProvider.create(value);
                    Navigator.pop(context);
                  },
                );
              },
            ),
            body: GridView.count(
              padding: const EdgeInsets.all(8),
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 24,
              childAspectRatio: 0.9,
              children: folderProvider.list
                  .map((FolderModel folder) => FolderListItem(
                        folder: folder,
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FoldersPage(folder: folder),
                            ),
                          );
                          folderProvider.changeFolder(null);
                        },
                        onLongPress: (BuildContext context) async {
                          var selected = await AlbumPopupMenu.showAlbumMenu(context: context);

                          if (selected == 1) {
                            var confirm = await showConfirmDialog(
                              context: context,
                              title: 'Deseja remover a pasta ${folder.name}?',
                            );

                            if (confirm) {
                              await folderProvider.remove(folder);
                            }
                          }
                        },
                      ))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
