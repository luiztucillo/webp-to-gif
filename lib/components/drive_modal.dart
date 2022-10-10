import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webp_to_gif/providers/google_drive_provider.dart';

showDriveModal(context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Consumer<GoogleDriveProvider>(builder: (
        context,
        googleDriveProvider,
        child,
      ) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 350),
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: FutureBuilder<bool>(
                  future: googleDriveProvider.isSigned(),
                  builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.hasData) {
                      return _content(googleDriveProvider, snapshot.data!);
                    }

                    return const CircularProgressIndicator();
                  },
                )),
          ),
        );
      });
    },
  );
}

Widget _content(GoogleDriveProvider googleDriveProvider, bool isLoggedIn) {
  if (isLoggedIn) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(googleDriveProvider.account!.email),
        _syncing(googleDriveProvider),
        TextButton(
          onPressed: () {
            googleDriveProvider.logout();
          },
          child: const Text('Sair'),
        ),
      ],
    );
  } else {
    return TextButton(
      onPressed: () {
        googleDriveProvider.login();
      },
      child: const Text('Login'),
    );
  }
}

Widget _syncing(GoogleDriveProvider googleDriveProvider) {
  if (!googleDriveProvider.isSyncing()) {
    return TextButton(
      onPressed: () {
        googleDriveProvider.sync();
      },
      child: const Text('Sincronizar'),
    );
  }

  return Text('Sincronizando: ${googleDriveProvider.getTotalSynced()} arquivos sincronizados de ${googleDriveProvider.getTotalFiles()}');
}
