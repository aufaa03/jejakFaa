// Salin ke: lib/features/home/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // <-- IMPORT PENTING
import 'package:jejak_faa_new/features/dashboard/screens/dashboard_page.dart';
import 'package:jejak_faa_new/features/gallery/screens/gallery_page.dart';
import 'package:jejak_faa_new/features/hike_log/screens/hike_list_page.dart';
import 'package:jejak_faa_new/features/home/providers/home_nav_provider.dart';
import 'package:jejak_faa_new/features/home/widgets/bottom_nav_bar.dart';
import 'package:jejak_faa_new/features/map_view/screens/map_page.dart';
import 'package:jejak_faa_new/features/profile/screens/profile_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const List<Widget> _pages = <Widget>[
    DashboardPage(),   // Index 0: Beranda
    HikeListPage(),    // Index 1: Jurnal
    MapPage(),         // Index 2: Peta
    GalleryPage(),     // Index 3: Galeri
    ProfilePage(),     // Index 4: Profil
  ];

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

    // --- TAMBAHAN UNTUK REDIRECT TAB (FIX BUG "RELOG") ---
    // 1. Ambil parameter 'tab' dari URL
    final String? tabString = GoRouterState.of(context).uri.queryParameters['tab'];

    // 2. Jika ada request pindah tab
    if (tabString != null) {
      final targetIndex = int.tryParse(tabString) ?? 0;
      
      // 3. Cek apakah kita perlu pindah tab (mencegah loop)
      if (currentIndex != targetIndex) {
        
        // 4. Lakukan perubahan state SETELAH frame selesai dirender
        //    Ini untuk menghindari error "setState/notifyListeners called during build"
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Update provider-nya
          ref.read(homeNavIndexProvider.notifier).state = targetIndex;
          
          // 5. (Opsional) Hapus parameter dari URL agar tidak 'terkunci'
          // Ini mencegah tab Peta terbuka lagi jika user pindah tab
          // lalu melakukan hot restart.
          context.replace('/home'); 
        });
      }
    }
    // --- AKHIR TAMBAHAN ---

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[currentIndex]),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: const BottomNavBar(),
      
      floatingActionButton: (currentIndex == 0 || currentIndex == 1)
          ? FloatingActionButton(
              onPressed: () => context.push('/home/add_hike'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}