import 'dart:async';
import 'package:jejak_faa_new/domain/repositories/sync_repository.dart';
import 'package:jejak_faa_new/data/local_db/database_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jejak_faa_new/core/services/connectivity_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'sync_provider.g.dart';

@riverpod
class Sync extends _$Sync {

  bool _isSyncLocked = false; // Penjaga untuk mencegah sinkronisasi ganda
  @override
  FutureOr<void> build() {
    print('[SyncProvider] Build: Memulai pemicu otomatis.');

    // --- PEMICU 1: Dengarkan Perubahan Koneksi Internet ---
    ref.listen<AsyncValue<List<ConnectivityResult>>>(
      connectivityStreamProvider,
      (previous, next) {
        _handleConnectivityChange(previous, next);
      },
      fireImmediately: true,
    );

    // --- PEMICU 2: Dengarkan Perubahan Jumlah Data Pending ---
    // ref.listen<AsyncValue<int>>(
    //   pendingHikesCountProvider,
    //   (previous, next) {
    //     _handlePendingCountChange(previous, next);
    //   },
    // );

    // --- PEMICU 3: Sync Awal Saat Aplikasi Dibuka ---
    Future.delayed(const Duration(seconds: 5), () {
      _triggerInitialSync();
    });

    return null;
  }

  // --- LOGIC PEMICU ---

  void _handleConnectivityChange(
      AsyncValue<List<ConnectivityResult>>? previous,
      AsyncValue<List<ConnectivityResult>> next) {
    if (next.hasError || !next.hasValue) return;
    final bool isOnline = !next.value!.contains(ConnectivityResult.none);
    final bool wasOffline =
        previous?.valueOrNull?.contains(ConnectivityResult.none) ?? false;

    if (isOnline && !state.isLoading && wasOffline) {
      print('[SyncProvider] Koneksi kembali online. Memicu sinkronisasi...');
      syncNow();
    }
  }

  void _handlePendingCountChange(
      AsyncValue<int>? previous, AsyncValue<int> next) {
    if (next.hasError || !next.hasValue) return;
    final int currentCount = next.value!;
    final int previousCount = previous?.valueOrNull ?? 0;

    if (currentCount > 0 && previousCount == 0 && !state.isLoading) {
       print('[SyncProvider] Data pending baru terdeteksi ($currentCount). Memicu sinkronisasi...');
       ref.read(connectivityStreamProvider.future).then((connectivityList) {
         final bool isOnline = !connectivityList.contains(ConnectivityResult.none);
         if (isOnline) {
           syncNow();
         } else {
           print('[SyncProvider] Batal sync (pemicu data baru): Tidak ada internet.');
         }
       });
    }
  }

  void _triggerInitialSync() {
    if (!state.isLoading) {
      print('[SyncProvider] Pemicu awal (5 detik). Memicu sinkronisasi...');
      // Cek internet dulu (meskipun syncNow juga ngecek, ini biar log lebih rapi)
      ref.read(connectivityStreamProvider.future).then((connectivityList) {
         final bool isOnline = !connectivityList.contains(ConnectivityResult.none);
         if (isOnline) {
           syncNow();
         } else {
           print('[SyncProvider] Batal sync (pemicu awal): Tidak ada internet.');
         }
       });
    }
  }


  // --- METHOD SINKRONISASI UTAMA (YANG DIPERBAIKI) ---
  Future<void> syncNow() async {
    // 1. Cek internet & state loading
    final connectivityList = await ref.read(connectivityStreamProvider.future);
    final bool isOnline = !connectivityList.contains(ConnectivityResult.none);
    
    if (state.isLoading) return; // Batal jika sedang loading

    if (_isSyncLocked) {
    print('[SyncProvider] Batal sync: Sinkronisasi lain sedang berjalan (locked).');
    return;
  }
  _isSyncLocked = true;

    if (!isOnline) {
      print('[SyncProvider] Batal sync (syncNow): Tidak ada internet.');
      return; // Batal jika tidak ada internet
    }
    // 2. Cek apakah pelacakan sedang aktif
    final prefs = await SharedPreferences.getInstance();
  if (prefs.getInt('ongoing_hike_id') != null) {
    print('[SyncProvider] Pelacakan sedang aktif. Sinkronisasi ditunda.');
    return; // LANGSUNG KELUAR
  }

    // =======================================================
    // == 2. "PENJAGA" (GUARD CLAUSE) YANG SALAH SUDAH DIHAPUS ==
    // =======================================================
    // 'pendingCount' check DIHAPUS dari sini.
    // Kita TETAP HARUS menjalankan syncRepository.syncPendingHikes()
    // walaupun pendingCount == 0, agar 'Sync-Down' (Tarik Data) bisa jalan.

    print('[SyncProvider] Memulai sinkronisasi 2 arah...');
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(syncRepositoryProvider);
      // 'syncPendingHikes' sekarang menjalankan 3 TUGAS:
      // 1. Sync-Down (Tarik data) -> INI YANG KITA MAU
      // 2. Sync-Up Inserts (Kirim baru)
      // 3. Sync-Up Updates (Kirim hapus/edit)
      await repository.syncPendingHikes(); 
      
      state = const AsyncValue.data(null);
      print('[SyncProvider] Sinkronisasi BERHASIL.');
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      print('[SyncProvider] Sinkronisasi GAGAL: $e');
    }
    finally {
      _isSyncLocked = false;
    }
  }
}
