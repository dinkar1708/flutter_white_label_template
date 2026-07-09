import 'package:flutter/material.dart';

import 'brand.dart';

class BrandConfig {
  final String appName;
  final Color seedColor;
  final String apiBaseUrl;
  final bool giftEnabled;

  const BrandConfig({
    required this.appName,
    required this.seedColor,
    required this.apiBaseUrl,
    required this.giftEnabled,
  });
}

const Map<Brand, BrandConfig> brandConfigs = {
  Brand.aqua: BrandConfig(
    appName: 'Aqua',
    seedColor: Colors.blue,
    apiBaseUrl: 'https://api.aqua.example.com',
    giftEnabled: true,
  ),
  Brand.coral: BrandConfig(
    appName: 'Coral',
    seedColor: Colors.orange,
    apiBaseUrl: 'https://api.coral.example.com',
    giftEnabled: false,
  ),
  Brand.amber: BrandConfig(
    appName: 'Amber',
    seedColor: Colors.yellow,
    apiBaseUrl: 'https://api.amber.example.com',
    giftEnabled: true,
  ),
};
