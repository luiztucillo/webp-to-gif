import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:webp_to_gif/services/drive_api.dart';
import 'package:webp_to_gif/services/google_auth_client.dart';

import '../models/image_model.dart';
import '../repositories/folder_repository.dart';
import '../repositories/image_repository.dart';

class GoogleDriveProvider extends ChangeNotifier {
  final GoogleSignIn _googleSignIn;
  GoogleSignInAccount? _account;
  bool get showAds => false;
  bool loading = false;

  bool _syncing = false;
  int _totalFiles = 0;
  int _totalSynced = 0;

  GoogleSignInAccount? get account => _account;

  GoogleDriveProvider() :_googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.driveScope]);

  Future<bool> isSigned() async {
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signInSilently();
      _account = _googleSignIn.currentUser;
      return true;
    }

    _account = null;
    return false;
  }

  _reset() async {
    _account = null;
    _syncing = false;
    _totalSynced = 0;
    _totalFiles = 0;
  }

  login() async {
    if (_account != null) {
      return;
    }

    _reset();

    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signInSilently();
      _account = _googleSignIn.currentUser;
    } else {
      _account = await _googleSignIn.signIn();
    }

    notifyListeners();
  }

  logout() async {
    if (_account == null) {
      _reset();
      return;
    }

    await _googleSignIn.signOut();
    notifyListeners();
  }

  int getTotalFiles() => _totalFiles;
  int getTotalSynced() => _totalSynced;
  bool isSyncing() => _syncing;

  sync() async {
    if (_account == null) {
      return;
    }

    _syncing = true;
    notifyListeners();

    final client = GoogleAuthClient(_account!);

    final driveApi = DriveApi(client);

    final folders = await FolderRepository().list();
    driveApi.clean();

    for (var i = 0; i <  folders.length; i ++) {
      final files = await ImageRepository().list(folders[i]);
      _totalFiles += files.length;
    }

    final basePath = await FolderRepository().basePath();

    notifyListeners();

    for (var i = 0; i <  folders.length; i ++) {
      if (_syncing == false || _account == null) {
        _reset();
        notifyListeners();
        break;
      }

      final localFolder = folders[i];
      final driveFolder = await driveApi.getFolder(localFolder.path.replaceAll(basePath, ''));

      if (driveFolder == null) {
        continue;
      }

      final files = await ImageRepository().list(localFolder);

      for (ImageModel img in files) {
        try {
          await driveApi.createFile(img, driveFolder);
          _totalSynced ++;
          notifyListeners();
        } catch(e) {
          //
        }
      }
    }

    _totalFiles = 0;
    _totalSynced = 0;
    _syncing = false;
    notifyListeners();
  }
}
