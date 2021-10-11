import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webp_to_gif/pages/albuns_page.dart';
import 'package:webp_to_gif/providers/ads_provider.dart';
import 'package:webp_to_gif/providers/folders_provider.dart';
import 'package:webp_to_gif/providers/share_provider.dart';
import 'package:webp_to_gif/theme.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FoldersProvider()),
        ChangeNotifierProvider(create: (context) => ShareProvider()),
        ChangeNotifierProvider(create: (context) => AdsProvider()),
      ],
      child: MaterialApp(
        title: 'WebpToGif',
        theme: AppTheme.getTheme(),
        home: const AlbunsPage(),
      ),
    );
  }
}
