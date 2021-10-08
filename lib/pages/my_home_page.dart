import 'package:webp_to_gif/components/app_dialogs.dart';
import 'package:webp_to_gif/components/folder_list_item.dart';
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
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Pastas'),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Center(
                    child: ListView(
                      children: folderProvider.list
                          .map((FolderModel folder) => FolderListItem(
                                folder: folder,
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FoldersPage(folder: folder),
                                    ),
                                  );
                                  folderProvider.changeFolder(null);
                                },
                                onDeletePressed: () async {
                                  await folderProvider.remove(folder);
                                },
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                showInputDialog(
                  context: context,
                  title: 'Criar pasta',
                  helperText: 'Nome da pasta',
                  onSubmitted: (String value) {
                    folderProvider.create(value);
                    Navigator.pop(context);
                  },
                );
              },
              child: const Icon(Icons.add),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          );
        },
      ),
    );
  }
}
