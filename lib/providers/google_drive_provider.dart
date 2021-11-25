import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:webp_to_gif/services/drive_api.dart';
import 'package:webp_to_gif/services/google_auth_client.dart';

class GoogleDriveProvider extends ChangeNotifier {
  bool get showAds => false;
  GoogleSignInAccount? _account;
  GoogleSignIn? _googleSignIn;
  bool loading = false;

  GoogleSignInAccount? get account => _account;

  GoogleDriveProvider() {
    init();
  }

  init() async {
    _googleSignIn = GoogleSignIn(
      scopes: [
        drive.DriveApi.driveScope,
      ],
    );

    if (await _googleSignIn!.isSignedIn()) {
      await _googleSignIn!.signInSilently();
    }

    _account = _googleSignIn!.currentUser;
    notifyListeners();
  }

  login() async {
    if (_googleSignIn == null) {
      init();
    }

    if (_account != null) {
      return;
    }

    _account = await _googleSignIn!.signIn();
    notifyListeners();
  }

  sync() async {
    loading = true;
    notifyListeners();

    final client = GoogleAuthClient(_account!);
    await DriveApi(client).sync();

    loading = false;
    notifyListeners();
  }
}
