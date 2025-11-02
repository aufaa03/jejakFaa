import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_nav_provider.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeNavIndexProvider);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) =>
          ref.read(homeNavIndexProvider.notifier).state = index,
      // Ganti label behavior biar kelihatan semua
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      backgroundColor: Theme.of(context).colorScheme.surface,
      destinations: const [
        // ===================================
        // == 1. TAB BARU (INDEX 0) ==
        // ===================================
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Beranda',
        ),

        // ===================================
        // == 2. JURNAL PINDAH (INDEX 1) ==
        // ===================================
        NavigationDestination(
          icon: Icon(Icons.summarize_outlined),
          selectedIcon: Icon(Icons.summarize),
          label: 'Jurnal',
        ),
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Peta',
        ),
        NavigationDestination(
          icon: Icon(Icons.photo_library_outlined),
          selectedIcon: Icon(Icons.photo_library),
          label: 'Galeri',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}

