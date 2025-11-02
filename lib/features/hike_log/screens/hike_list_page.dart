import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import provider baru kita
import 'package:jejak_faa_new/features/hike_log/providers/hike_provider.dart';
// Import widget card
import 'package:jejak_faa_new/features/hike_log/widgets/hike_card.dart';
// Import class 'Hike' dari Drift
import 'package:jejak_faa_new/data/local_db/database.dart';

// ==========================================================
// KODE DUMMY (DummyHike) SUDAH DIHAPUS DI SINI
// ==========================================================

class HikeListPage extends ConsumerWidget {
  const HikeListPage({super.key});

  @override
  Widget build(BuildContext, WidgetRef ref) {
    // 1. Tonton provider stream yang baru
    final hikeListAsync = ref.watch(hikeListStreamProvider);

    // 2. Gunakan 'when' untuk handle state (loading, error, data)
    return hikeListAsync.when(
      // --- State Sukses (Ada Data) ---
      data: (hikes) {
        // Tampilan jika data masih kosong
        if (hikes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.landscape_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum Ada Jejak',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tekan tombol ➕ di bawah untuk mencatat pendakian pertamamu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        // Tampilan jika ada data
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          itemCount: hikes.length,
          itemBuilder: (context, index) {
            final hike = hikes[index];
            // 3. Kirim data 'Hike' (dari Drift) ke HikeCard
            return HikeCard(hike: hike);
          },
        );
      },
      // --- State Error ---
      error: (error, stackTrace) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error memuat data:\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
      // --- State Loading ---
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

