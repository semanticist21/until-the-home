import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../utils/app_logger.dart';

class AppAdBanner extends StatefulWidget {
  const AppAdBanner({super.key});

  @override
  State<AppAdBanner> createState() => _AppAdBannerState();
}

class _AppAdBannerState extends State<AppAdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // Production ad unit IDs
  static String get _adUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6737616702687889/1500674457';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-6737616702687889/1697961485';
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Check if ads should be shown (release mode + supported platform)
  static bool get _shouldShowAds {
    return !kDebugMode && (Platform.isAndroid || Platform.isIOS);
  }

  @override
  void initState() {
    super.initState();
    appLogger.i(
      '[APP_AD_BANNER] initState - shouldShowAds: $_shouldShowAds, kDebugMode: $kDebugMode, platform: ${Platform.operatingSystem}',
    );
    if (_shouldShowAds) {
      _loadAd();
    } else {
      appLogger.w(
        '[APP_AD_BANNER] Ads disabled - debug mode or unsupported platform',
      );
    }
  }

  void _loadAd() {
    final adUnitId = _adUnitId;
    appLogger.i('[APP_AD_BANNER] Loading ad with unit ID: $adUnitId');

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          appLogger.i('[APP_AD_BANNER] ✅ Ad loaded successfully');
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          appLogger.e(
            '[APP_AD_BANNER] ❌ Ad failed to load - Code: ${error.code}, Message: ${error.message}, Domain: ${error.domain}',
            error: error,
          );
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowAds) {
      return const SizedBox.shrink();
    }

    if (!_isLoaded || _bannerAd == null) {
      appLogger.d(
        '[APP_AD_BANNER] build - ad not ready (loaded: $_isLoaded, ad: ${_bannerAd != null})',
      );
      return const SizedBox.shrink();
    }

    appLogger.d('[APP_AD_BANNER] build - showing ad banner');
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
