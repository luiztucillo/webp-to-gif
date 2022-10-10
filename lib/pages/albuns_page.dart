import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:webp_to_gif/components/album_popup_menu.dart';
import 'package:webp_to_gif/components/app_dialogs.dart';
import 'package:webp_to_gif/components/drive_modal.dart';
import 'package:webp_to_gif/components/folder_list_item.dart';
import 'package:webp_to_gif/components/layout.dart';
import 'package:webp_to_gif/models/folder_model.dart';
import 'package:webp_to_gif/providers/folders_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webp_to_gif/providers/google_drive_provider.dart';
import 'package:webp_to_gif/providers/share_provider.dart';
import 'package:webp_to_gif/services/drive_api.dart';
import 'package:webp_to_gif/services/google_auth_client.dart';

import 'images_page.dart';

class AlbunsPage extends StatelessWidget {
  const AlbunsPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer3<FoldersProvider, GoogleDriveProvider, ShareProvider>(
      builder: (
        context,
        folderProvider,
        googleDriveProvider,
        shareProvider,
        child,
      ) {
        if (shareProvider.sharedFiles != null) {
          return shareProvider.widget(onShare: (
            List<SharedMediaFile> sharedFiles,
            FolderModel folder,
          ) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ImagesPage(
                  folder: folder,
                  shared: sharedFiles,
                ),
              ),
            );
          });
        }

        return Layout(
          title: 'Álbuns',
          subtitle: '${folderProvider.folderCount} álbuns',
          showLeading: false,
          barActions: Row(
            children: [
              IconButton(
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
              IconButton(
                icon: Icon(Icons.add_to_drive),
                onPressed: () {
                  showDriveModal(context);
                },
              ),
            ],
          ),
          body: GridView.count(
            padding: const EdgeInsets.all(8),
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 24,
            childAspectRatio: 0.9,
            children: folderProvider.list
                .map(
                  (FolderModel folder) => FolderListItem(
                    folder: folder,
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ImagesPage(folder: folder),
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
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
