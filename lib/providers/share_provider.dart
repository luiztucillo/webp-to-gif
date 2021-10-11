import 'dart:async';

import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:webp_to_gif/models/folder_model.dart';
import 'package:webp_to_gif/pages/shared_page.dart';

class ShareProvider extends ChangeNotifier {
  StreamSubscription? _intentDataStreamSubscription;
  List<SharedMediaFile>? _sharedFiles;

  List<SharedMediaFile>? get sharedFiles => _sharedFiles;

  ShareProvider() {
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen(_setSharedFiles, onError: (err) {});

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then(_setSharedFiles);
  }

  Widget widget({
    required Function(List<SharedMediaFile>, FolderModel) onShare,
  }) =>
      SharedPage(
        onShare: (List<SharedMediaFile> files, FolderModel folder) {
          _intentDataStreamSubscription?.cancel();
          onShare(files, folder);
        },
      );

  _setSharedFiles(List<SharedMediaFile> files) {
    if (files.isEmpty) {
      return;
    }

    _sharedFiles = files;

    notifyListeners();
  }

  finishShare() {
    _sharedFiles = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _intentDataStreamSubscription?.cancel();
  }
}
