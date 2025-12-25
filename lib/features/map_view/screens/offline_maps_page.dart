import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OfflineMapsPage extends ConsumerWidget {
  const OfflineMapsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unduh Peta Offline'),
      ),
      body: const Center(
        child: Text('Halaman untuk mengunduh peta akan ada di sini.'),
      ),
    );
  }
}