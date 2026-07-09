import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/store.dart';
import '../providers/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(brandConfigProvider);
    final storesAsync = ref.watch(storesProvider);
    debugPrint(
      '[HomeScreen] build — appName="${config.appName}" '
      'stores.isLoading=${storesAsync.isLoading} '
      'stores.hasValue=${storesAsync.hasValue} '
      'stores.count=${storesAsync.asData?.value.length}',
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(config.appName),
      ),
      body: storesAsync.when(
        loading: () {
          debugPrint('[HomeScreen] storesProvider: loading…');
          return const Center(child: CircularProgressIndicator());
        },
        error: (err, _) {
          debugPrint('[HomeScreen] storesProvider: ERROR $err');
          return Center(child: Text('Failed to load stores: $err'));
        },
        data: (stores) {
          debugPrint(
            '[HomeScreen] storesProvider: data — '
            '${stores.length} stores: '
            '${stores.map((s) => s.name).toList()}',
          );
          return ListView.separated(
            itemCount: stores.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) => _StoreTile(store: stores[i]),
          );
        },
      ),
      // Golden rule: gate features by capability (config.giftEnabled),
      // never by brand identity (brand == Brand.coral).
      floatingActionButton: config.giftEnabled
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gifts coming soon')),
                );
              },
              icon: const Icon(Icons.card_giftcard),
              label: const Text('Gifts'),
            )
          : null,
    );
  }
}

class _StoreTile extends StatelessWidget {
  const _StoreTile({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(store.name),
      subtitle: Text(store.category),
      trailing: Text(
        '${store.discountPercent}% off',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
