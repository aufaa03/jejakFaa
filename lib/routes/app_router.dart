import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jejak_faa_new/data/local_db/database.dart'; // <-- Import 'Hike'
import 'package:jejak_faa_new/features/auth/providers/auth_provider.dart';
import 'package:jejak_faa_new/features/auth/screens/login_page.dart';
import 'package:jejak_faa_new/features/home/screens/home_page.dart';
import 'package:jejak_faa_new/features/hike_log/screens/hike_form_page.dart';
import 'package:jejak_faa_new/features/hike_log/screens/hike_detail_page.dart';
import 'package:jejak_faa_new/features/map_view/screens/weather_forecast_page.dart';
import 'package:jejak_faa_new/features/map_view/screens/offline_maps_page.dart';
import 'package:jejak_faa_new/features/profile/screens/edit_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jejak_faa_new/features/splash/screens/splash_page.dart';
import 'package:jejak_faa_new/features/splash/screens/onboarding_page.dart';


// Provider untuk GoRouter
final appRouterProvider = Provider<GoRouter>((ref) {
  // Tonton status autentikasi
  final authState = ref.watch(authStateProvider);
  // Ambil repository auth (untuk stream refresh)
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    // Dengarkan perubahan auth state untuk redirect otomatis
    refreshListenable: GoRouterRefreshStream(authRepository.onAuthStateChange),
    // Halaman awal saat aplikasi dibuka
    initialLocation: '/onboarding',
    // Daftar semua rute/halaman dalam aplikasi
    routes: [
      // Rute Splash Screen (loading)
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      //rute 
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      // Rute Halaman Login
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      // Rute Halaman Utama (setelah login)
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(), // Induk 5 tab
        // Daftarkan halaman yang diakses DARI DALAM tab
        // sebagai rute 'anak' (child routes)
        routes: [
          GoRoute(
            path: 'add_hike', // <-- HAPUS '/' di depan
            name: 'add_hike', // Beri nama agar mudah dipanggil
            pageBuilder: (context, state) => const MaterialPage(
              fullscreenDialog: true,
              child: HikeFormPage(),
            ),
          ),
          GoRoute(
            path: 'edit_hike', // <-- HAPUS '/' di depan
            name: 'edit_hike', // Beri nama
            pageBuilder: (context, state) {
              final hikeToEdit = state.extra as Hike?;
              return MaterialPage(
                fullscreenDialog: true,
                child: HikeFormPage(hikeToEdit: hikeToEdit),
              );
            },
          ),
          GoRoute(
            path: 'hike_detail/:hikeId', // <-- HAPUS '/' di depan
            name: 'hike_detail', // Beri nama
            builder: (context, state) {
              final String hikeIdStr = state.pathParameters['hikeId'] ?? '0';
              final int hikeId = int.tryParse(hikeIdStr) ?? 0;
              return HikeDetailPage(localHikeId: hikeId);
            },
          ),

          GoRoute(
            path: 'weather', // path: '/home/weather'
            builder: (context, state) => const WeatherForecastPage(),
          ),
          GoRoute(
            path: 'offline_maps', // path: /home/offline_maps
            builder: (context, state) => const OfflineMapsPage(),
          ),

          GoRoute(
            path: 'edit_profile', // -> /home/edit_profile
            builder: (context, state) => const EditProfilePage(),
          ),
        ],
      ),
      // Rute untuk Tambah Jejak (dibuka sebagai modal)
      // GoRoute(
      //   path: '/add_hike',
      //   // pageBuilder digunakan agar bisa tampil sebagai modal
      //   pageBuilder: (context, state) => const MaterialPage(
      //     fullscreenDialog: true, // Tampil dari bawah
      //     child: HikeFormPage(), // Panggil Form tanpa argumen (mode Tambah)
      //   ),
      // ),
      // // Rute Baru untuk Edit Jejak (dibuka sebagai modal)
      // GoRoute(
      //   path: '/edit_hike',
      //   pageBuilder: (context, state) {
      //     // Ambil objek 'Hike' yang dikirim sebagai 'extra' dari HikeCard
      //     final hikeToEdit = state.extra as Hike?;
      //     return MaterialPage(
      //       fullscreenDialog: true, // Tampil dari bawah
      //       // Panggil Form DENGAN argumen (mode Edit)
      //       child: HikeFormPage(hikeToEdit: hikeToEdit),
      //     );
      //   },
      // ),
      //  GoRoute(
      //   // Pakai ':hikeId' untuk parameter dinamis
      //   path: '/hike_detail/:hikeId',
      //   builder: (context, state) {
      //     // Ambil ID dari path
      //     final String hikeIdStr = state.pathParameters['hikeId'] ?? '0';
      //     // Konversi ke integer
      //     final int hikeId = int.tryParse(hikeIdStr) ?? 0;
      //     // Kirim ID ke Halaman Detail
      //     return HikeDetailPage(localHikeId: hikeId);
      //   },
      // ),
    ],
    // Logika redirect otomatis berdasarkan status login
    redirect: (BuildContext context, GoRouterState state) async {
      final bool isLoggedIn = authState.value != null;
      final bool isLoading = authState.isLoading;
      final bool isSplash = state.matchedLocation == '/splash';
      final prefs = await SharedPreferences.getInstance();
      // final bool onboardingComplete = prefs.getBool(kOnboardingCompleteKey) ?? false ;
      // Halaman yang boleh diakses saat loading atau belum login
  final bool onAllowedPage = 
      state.matchedLocation == '/login' ||
      state.matchedLocation == '/onboarding' ||
      state.matchedLocation == '/splash';

  // 1. Saat loading, biarkan di halaman yang diizinkan (terutama splash)
  if (isLoading || (authState.isRefreshing && !authState.hasValue)) {
    // Jika sedang loading DAN tidak di halaman yg diizinkan, paksa ke splash
    if (!onAllowedPage) {
      return '/splash';
    }
    return null; // Biarkan (misal: tetap di /splash)
  }

  // 2. Jika sudah selesai loading dan BELUM LOGIN
  if (!isLoggedIn) {
    // Jika tidak di salah satu halaman yg diizinkan, paksa ke login
    // Ini mengizinkan kita tetap di /onboarding atau /splash
    if (!onAllowedPage) {
      return '/login';
    }
    
    // Khusus untuk DEMO: Jika kita dari splash dan mau ke login, 
    // kita paksa ke onboarding
    // Tapi ini tidak perlu, initialLocation sudah handle.
    // Biarkan saja.
    return null; 
  }

  // 3. Jika SUDAH LOGIN
  if (isLoggedIn) {
    // Jika sudah login tapi masih di halaman auth/splash, lempar ke home
    if (onAllowedPage) {
      return '/home';
    }
      // Cek "Buku Log" (Prefs)
      final status = prefs.getString('tracking_status');
      
      // Cek apakah user ada di halaman '/home' (Dashboard)
      final bool onHomePage = state.matchedLocation == '/home';

      // Jika sedang tracking (bukan 'paused') DAN ada di Dashboard
      if (status == 'tracking' && onHomePage) {
        // Paksa pindah ke halaman Peta!
        return '/home?tab=2';
      }

      // Kondisi lain, biarkan
      return null;
  }
    }
  );
});

// Helper class untuk membuat GoRouter 'listen' ke Stream (auth state)
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    // Beri tahu GoRouter saat pertama kali dibuat
    notifyListeners();
    // Dengarkan stream, beri tahu GoRouter setiap ada data baru
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  // Jangan lupa batalkan subscription saat tidak dipakai
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
