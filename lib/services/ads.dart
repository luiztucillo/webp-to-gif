// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

const IS_TEST = false;

const ANDROID_BANNER_TEST_ID = 'ca-app-pub-3940256099942544/6300978111';
const ANDROID_BANNER_FINAL_ID = 'ca-app-pub-4138453881791255/4096294236';
const ANDROID_INTERSTITIAL_TEST_ID = 'ca-app-pub-3940256099942544/8691691433';
const ANDROID_INTERSTITIAL_FINAL_ID = 'ca-app-pub-4138453881791255/7145129403';

const IOS_BANNER_TEST_ID = 'ca-app-pub-3940256099942544/6300978111';
const IOS_BANNER_FINAL_ID = 'ca-app-pub-4138453881791255/4096294236';
const IOS_INTERSTITIAL_TEST_ID = 'ca-app-pub-3940256099942544/1033173712';
const IOS_INTERSTITIAL_FINAL_ID = 'ca-app-pub-4138453881791255/7145129403';

class Ads {
  InterstitialAd? _convertingAd;
  BannerAd? _gridBanner;
  bool _gridBannedLoaded = false;

  loadConvertingAd() {
    InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? (IS_TEST ? ANDROID_INTERSTITIAL_TEST_ID : ANDROID_INTERSTITIAL_FINAL_ID)
          : (IS_TEST ? IOS_INTERSTITIAL_TEST_ID : IOS_INTERSTITIAL_FINAL_ID),
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
          ? (IS_TEST ? ANDROID_BANNER_TEST_ID : ANDROID_BANNER_FINAL_ID)
          : (IS_TEST ? IOS_BANNER_TEST_ID : IOS_BANNER_FINAL_ID),
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

  Widget gridWidget() {
    if (!_gridBannedLoaded) {
      return Container();
    }

    return AdWidget(ad: _gridBanner!);
  }
}
