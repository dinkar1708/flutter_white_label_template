import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_white_label_template/brand/brand.dart';
import 'package:flutter_white_label_template/models/store.dart';
import 'package:flutter_white_label_template/providers/brand_providers.dart';
import 'package:flutter_white_label_template/providers/store_providers.dart';
import 'package:flutter_white_label_template/screens/home_screen.dart';

const _aquaStores = [
  Store(id: 'aq-1', name: 'Ocean Cafe', category: 'Food', discountPercent: 10),
  Store(id: 'aq-2', name: 'Wave Boutique', category: 'Fashion', discountPercent: 15),
  Store(id: 'aq-3', name: 'Pearl Books', category: 'Books', discountPercent: 5),
];

const _coralStores = [
  Store(id: 'co-1', name: 'Sunset Diner', category: 'Food', discountPercent: 12),
  Store(id: 'co-2', name: 'Reef Records', category: 'Music', discountPercent: 20),
];

Widget _harness({
  required Brand brand,
  required List<Store> stores,
}) {
  return ProviderScope(
    overrides: [
      brandProvider.overrideWith((ref) => brand),
      storesProvider.overrideWith((ref) => Future.value(stores)),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  testWidgets('aqua: shows appName, all 3 stores, and Gifts FAB',
      (tester) async {
    await tester.pumpWidget(_harness(brand: Brand.aqua, stores: _aquaStores));
    await tester.pumpAndSettle();

    expect(find.text('Aqua'), findsOneWidget);
    expect(find.text('Ocean Cafe'), findsOneWidget);
    expect(find.text('Wave Boutique'), findsOneWidget);
    expect(find.text('Pearl Books'), findsOneWidget);
    expect(find.text('10% off'), findsOneWidget);
    expect(find.text('Gifts'), findsOneWidget);
    expect(find.byIcon(Icons.card_giftcard), findsOneWidget);
  });

  testWidgets('coral: shows appName, 2 stores, and NO Gifts FAB',
      (tester) async {
    await tester.pumpWidget(_harness(brand: Brand.coral, stores: _coralStores));
    await tester.pumpAndSettle();

    expect(find.text('Coral'), findsOneWidget);
    expect(find.text('Sunset Diner'), findsOneWidget);
    expect(find.text('Reef Records'), findsOneWidget);

    // Golden rule proof: Gifts FAB absent even though the widget code
    // never checks `brand == Brand.coral` — only config.giftEnabled.
    expect(find.text('Gifts'), findsNothing);
    expect(find.byIcon(Icons.card_giftcard), findsNothing);
  });

  testWidgets('shows loading indicator before stores resolve',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          brandProvider.overrideWith((ref) => Brand.aqua),
          storesProvider.overrideWith(
            (ref) => Future.delayed(
              const Duration(milliseconds: 200),
              () => _aquaStores,
            ),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // First frame — future is still pending.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    // After the future resolves, the list is visible.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Ocean Cafe'), findsOneWidget);
  });

  testWidgets('tapping Gifts FAB shows a snackbar', (tester) async {
    await tester.pumpWidget(_harness(brand: Brand.aqua, stores: _aquaStores));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gifts'));
    await tester.pump();

    expect(find.text('Gifts coming soon'), findsOneWidget);
  });
}
