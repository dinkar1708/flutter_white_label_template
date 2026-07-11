import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'brand/brand.dart';
import 'providers/brand_providers.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Keep the semantics tree populated at all times so external UI test
  // runners (Maestro, UIAutomator, Espresso) can discover widgets by text.
  // The returned SemanticsHandle is intentionally leaked — disposing it
  // would turn semantics off again.
  SemanticsBinding.instance.ensureSemantics();

  final info = await PackageInfo.fromPlatform();
  debugPrint(
    '[boot] brand=${currentBrand.name} '
    'appId=${info.packageName} '
    'appName="${info.appName}" '
    'version=${info.version}+${info.buildNumber}',
  );

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
