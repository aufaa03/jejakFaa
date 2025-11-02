import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jejak_faa_new/features/dashboard/screens/dashboard_page.dart'; // <-- 1. IMPORT HALAMAN BARU
import 'package:jejak_faa_new/features/gallery/screens/gallery_page.dart';
import 'package:jejak_faa_new/features/hike_log/screens/hike_list_page.dart';
import 'package:jejak_faa_new/features/home/providers/home_nav_provider.dart';
import 'package:jejak_faa_new/features/home/widgets/bottom_nav_bar.dart';
import 'package:jejak_faa_new/features/map_view/screens/map_page.dart';
import 'package:jejak_faa_new/features/profile/screens/profile_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  // 2. UPDATE DAFTAR HALAMAN (TOTAL 5)
  static const List<Widget> _pages = <Widget>[
    DashboardPage(), // <-- Index 0: Beranda
    HikeListPage(),  // <-- Index 1: Jurnal
    MapPage(),       // <-- Index 2: Peta
    GalleryPage(),   // <-- Index 3: Galeri
    ProfilePage(),   // <-- Index 4: Profil
  ];

  // 3. UPDATE DAFTAR JUDUL (TOTAL 5)
  static const List<String> _titles = <String>[
    'Beranda',
    'Jurnal Pendakian',
    'Peta',
    'Galeri',
    'Profil Saya',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeNavIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[currentIndex]),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: const BottomNavBar(),
      
      // =======================================================
      // 4. LOGIKA FAB (TOMBOL +) JADI PINTAR
      // =======================================================
      floatingActionButton: (currentIndex == 0 || currentIndex == 1)
          ? FloatingActionButton(
              onPressed: () => context.push('/home/add_hike'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              child: const Icon(Icons.add),
            )
          : null, // <-- Sembunyikan FAB di halaman Peta, Galeri, Profil
    );
  }
}

