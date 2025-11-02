import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/database_providers.dart';
import 'package:jejak_faa_new/features/auth/providers/auth_provider.dart';
import 'package:jejak_faa_new/features/sync/providers/sync_provider.dart';
import 'package:jejak_faa_new/features/hike_log/providers/hike_list_provider.dart';
import 'package:jejak_faa_new/features/hike_log/widgets/hike_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // <-- 'ref' ada di sini
    // Ambil nama user
    final authState = ref.watch(authStateProvider);
    final userName = authState.value?.name ?? 'Pendaki';

    // Tonton status sinkronisasi
    final syncState = ref.watch(syncProvider);
    final pendingCount = ref.watch(pendingHikesCountProvider);

    // Tonton data list pendakian
    final hikeListAsync = ref.watch(hikeListStreamProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // --- 1. Header Sambutan ---
          Text(
            'Halo, $userName 👋',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selamat datang kembali, jejakmu aman bersama kami.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),

          // --- 2. Kartu Status Sinkronisasi ---
          _buildSyncStatusCard(context, syncState, pendingCount),

          const SizedBox(height: 24),

          // --- 3. Kartu Statistik ---
          // ============================================
          // == OPER 'ref' SAAT MEMANGGIL ==
          // ============================================
          _buildStatsCard(context, ref), // <-- Oper 'ref' ke sini

          const SizedBox(height: 24),

          // --- 4. Pendakian Terakhir ---
          Text(
            'Pendakian Terakhir',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Gunakan .when untuk handle loading/error/data
          hikeListAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text('Error memuat data: $err'),
            ),
            data: (hikes) {
              if (hikes.isEmpty) {
                return Center(
                  child: Text(
                    'Belum ada data pendakian.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                );
              }
              // Ambil maksimal 3 data teratas
              final recentHikes = hikes.take(3).toList();
              // Tampilkan pakai Column
              return Column(
                children: recentHikes.map((hike) {
                  // Gunakan HikeCard yang sudah ada
                  return HikeCard(hike: hike);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget _buildSyncStatusCard (tetap sama)
  Widget _buildSyncStatusCard(BuildContext context,
      AsyncValue<void> syncState, AsyncValue<int> pendingCount) {
    // ... (kode tetap sama) ...
    final theme = Theme.of(context);

    Widget content;
    Color cardColor;
    Color iconColor;
    IconData icon;
    String title, subtitle;

    if (syncState.isLoading) {
      cardColor = Colors.blue.shade50;
      iconColor = Colors.blue.shade800;
      icon = Icons.cloud_sync_outlined;
      title = 'Sinkronisasi...';
      subtitle = 'Menyimpan jejak terbaru ke cloud...';
    } else if (pendingCount.valueOrNull != null && pendingCount.value! > 0) {
      cardColor = Colors.orange.shade50;
      iconColor = Colors.orange.shade800;
      icon = Icons.warning_amber_rounded;
      title = '${pendingCount.value} Jejak Menunggu';
      subtitle = 'Data akan dicadangkan otomatis saat internet stabil.';
    } else {
      cardColor = theme.colorScheme.primaryContainer.withOpacity(0.3);
      iconColor = theme.colorScheme.primary;
      icon = Icons.cloud_done_outlined;
      title = 'Semua Jejak Aman';
      subtitle = 'Data kamu sudah tersimpan di cloud.';
    }

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: iconColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (syncState.isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Kartu Statistik
  // ============================================
  // == TAMBAHKAN PARAMETER 'WidgetRef ref' ==
  // ============================================
  Widget _buildStatsCard(BuildContext context, WidgetRef ref) { // <-- Tambah ref di sini
    // Sekarang kita bisa watch provider di sini
    final totalHikes = ref.watch(hikeListStreamProvider).valueOrNull?.length ?? 0;

    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(totalHikes.toString(),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('Total Jejak'),
              ],
            ),
            const Column(
              children: [
                Text('0 km',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Total Jarak'), // Nanti kita hitung
              ],
            ),
          ],
        ),
      ),
    );
  }
}

