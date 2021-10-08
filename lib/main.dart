import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webp_to_gif/components/app_dialogs.dart';
import 'package:webp_to_gif/pages/my_home_page.dart';
import 'package:webp_to_gif/pages/shared_page.dart';
import 'package:webp_to_gif/theme.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _intentDataStreamSubscription;
  List<SharedMediaFile>? _sharedFiles;

  @override
  void initState() {
    super.initState();

    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen(_setSharedFiles, onError: (err) {});

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then(_setSharedFiles);
  }

  _setSharedFiles(List<SharedMediaFile> files) {
    if (files.isEmpty) {
      return;
    }

    setState(() {
      _sharedFiles = files;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebpToGif',
      theme: AppTheme.getTheme(),
      home: _sharedFiles != null
          ? SharedPage(
              files: _sharedFiles!,
              finishShare: () {
                setState(() {
                  _sharedFiles = null;
                });
              },
            )
          : const MyHomePage(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _intentDataStreamSubscription?.cancel();
  }
}
