import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'brand/brand.dart';
import 'providers/brand_providers.dart';
import 'screens/home_screen.dart';

void main() {
  debugPrint('[boot] main() — currentBrand=${currentBrand.name}');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(brandConfigProvider);
    debugPrint(
      '[MyApp] build — appName="${config.appName}" '
      'seedColor=${config.seedColor} '
      'giftEnabled=${config.giftEnabled}',
    );
    return MaterialApp(
      title: config.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: config.seedColor),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
