import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';
// 1. IMPORT DAO KITA
import 'package:jejak_faa_new/data/local_db/database_providers.dart';
import 'package:jejak_faa_new/data/models/sync_status.dart'; // <-- 2. IMPORT ENUM
import 'package:intl/intl.dart';


// 3. GANTI DARI KODE ANDA KE VERSI DISMISSIBLE
class HikeCard extends ConsumerWidget {
  final Hike hike;
  const HikeCard({super.key, required this.hike});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Format tanggal
    final dateText =
        '${hike.hikeDate.day}/${hike.hikeDate.month}/${hike.hikeDate.year}';

    // 4. Tentukan status sinkronisasi untuk UI (MENGGUNAKAN ENUM)
    IconData syncIcon;
    Color syncColor;
    String syncTooltip;

    switch (hike.syncStatus) {
      case SyncStatus.synced:
        syncIcon = Icons.cloud_done_outlined;
        syncColor = Colors.green.shade700;
        syncTooltip = 'Aman (Sudah disinkronisasi)';
        break;
      case SyncStatus.pending:
      case SyncStatus.pending_update:
        syncIcon = Icons.cloud_upload_outlined;
        syncColor = Colors.blue.shade700;
        syncTooltip = 'Menunggu sinkronisasi';
        break;
      default: // Harusnya tidak terjadi
        syncIcon = Icons.cloud_off_outlined;
        syncColor = Colors.grey;
        syncTooltip = 'Status tidak diketahui';
    }


    // 5. BUNGKUS CARD DENGAN 'DISMISSIBLE' (Geser-untuk-Hapus)
    return Dismissible(
      // 6. Kunci unik untuk widget ini
      key: ValueKey(hike.id),

      // 7. Arah geser (hanya dari kanan ke kiri)
      direction: DismissDirection.endToStart,

      // 8. Tampilan background saat di-geser (Ikon Sampah)
      background: Container(
        margin: const EdgeInsets.only(bottom: 12.0), // Samakan margin card
        decoration: BoxDecoration(
          color: Colors.red[700],
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_sweep_outlined,
          color: Colors.white,
          size: 28,
        ),
      ),

      // 9. AKSI SAAT DI-GESER PENUH (SOFT DELETE)
      onDismissed: (direction) {
        // Ambil DAO dan panggil method 'softDeleteHike' (INI AKAN KITA BUAT DI 'hike_dao.dart')
        ref.read(hikeDaoProvider).softDeleteHike(hike.id);

        // Tampilkan notifikasi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${hike.mountainName} ditandai untuk dihapus.'),
            backgroundColor: Colors.red[800],
          ),
        );
      },

      // 10. CARD ASLINYA
      child: InkWell(
        onTap: () {
          // Navigasi ke halaman detail dengan mengirim ID lokal
          context.push('/home/hike_detail/${hike.id}');
        },
        borderRadius: BorderRadius.circular(16.0), // Efek splash rounded
        child: Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Judul (Nama Gunung, Status, Tombol Edit)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Gunung & Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hike.mountainName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Indikator Status Sync (Badge)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: syncColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(syncIcon, size: 12, color: syncColor),
                                const SizedBox(width: 4),
                                Text(
                                  syncTooltip,
                                  style: TextStyle(
                                    color: syncColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tombol Edit
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Edit Jejak',
                      onPressed: () {
                        // Buka halaman Form mode Edit
                        context.push('/home/edit_hike', extra: hike);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Baris Info (Tanggal & Durasi)
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(dateText, style: theme.textTheme.bodyMedium),
                    const SizedBox(width: 16),
                    if (hike.durationMinutes != null) ...[
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${hike.durationMinutes} menit',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),

                // Baris Info (Partner)
                if (hike.partners != null && hike.partners!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(hike.partners!, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ],

                // Catatan (ringkasan)
                if (hike.notes != null && hike.notes!.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(
                    hike.notes!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 3, // Tampilkan maks 3 baris
                    overflow:
                        TextOverflow.ellipsis, // Tambahkan '...' jika panjang
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

