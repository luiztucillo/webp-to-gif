import 'package:flutter/material.dart';
import 'package:webp_to_gif/pages/my_home_page.dart';
import 'package:webp_to_gif/theme.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebpToGif',
      theme: AppTheme.getTheme(),
      home: const MyHomePage(),
    );
  }
}
