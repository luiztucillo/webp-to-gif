import 'dart:math';

import 'package:webp_to_gif/models/folder_model.dart';
import 'package:webp_to_gif/pages/folders_page.dart';
import 'package:webp_to_gif/providers/folders_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => FoldersProvider(),
      child: Consumer<FoldersProvider>(
        builder:
            (BuildContext context, FoldersProvider folders, Widget? child) {
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
                      children: folders.items
                          .map(
                            (FolderModel folder) => Container(
                              key: Key(folder.id.toString()),
                              padding: const EdgeInsets.all(8),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blue[50],
                                ),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FoldersPage(
                                        folder: folder,
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.folder,
                                      color: folder.color,
                                      size: 30,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      folder.name,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Expanded(child: Container()),
                                    TextButton(
                                      onPressed: () async {
                                        await folders.remove(folder);
                                      },
                                      child: const Icon(
                                        Icons.delete,
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                TextEditingController controller = TextEditingController();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Qual o nome da pasta?'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(),
                        onSubmitted: (String value) {
                          folders.add(FolderModel(
                            name: value,
                            color: Colors.primaries[
                                Random().nextInt(Colors.primaries.length)],
                          ));
                          Navigator.pop(context);
                        },
                      ),
                    );
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
