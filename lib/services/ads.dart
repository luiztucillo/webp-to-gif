import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Ads {
  InterstitialAd? _convertingAd;
  BannerAd? _gridBanner;
  bool _gridBannedLoaded = false;

  loadConvertingAd() {
    InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-4138453881791255/4096294236'
          : 'ca-app-pub-3940256099942544/4411468910',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _convertingAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          //
        },
      ),
    );
  }

  disposeAds() {
    _convertingAd?.dispose();
    _gridBanner?.dispose();
  }

  showConvertingAd() {
    _convertingAd?.show();
  }

  loadGridAd(VoidCallback onLoad) {
    _gridBanner = BannerAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-4138453881791255/7145129403'
          : 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.fullBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _gridBannedLoaded = true;
          onLoad();
        },
      ),
    );

    _gridBanner!.load();
  }

  get gridAd => _gridBannedLoaded ? _gridBanner : null;
}
