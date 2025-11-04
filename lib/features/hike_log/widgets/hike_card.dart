import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/database_providers.dart';
import 'package:jejak_faa_new/data/models/sync_status.dart';
import 'package:intl/intl.dart';

// --- TAMBAHKAN FUNGSI HELPER DI SINI ---
String _formatDuration(int? totalSeconds) {
  if (totalSeconds == null) return '0d';
  
  final duration = Duration(seconds: totalSeconds);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  final parts = <String>[];
  if (hours > 0) {
    parts.add('${hours}j');
  }
  if (minutes > 0) {
    parts.add('${minutes}m');
  }
  // Hanya tampilkan detik jika durasi kurang dari 1 jam
  if (hours == 0) {
    parts.add('${seconds}d');
  }
  // Jika 0 detik, tampilkan 0d
	if (parts.isEmpty && totalSeconds == 0) {
    return '0d';
  }

  return parts.join(' ');
}
// --- AKHIR FUNGSI HELPER ---


class HikeCard extends ConsumerWidget {
  final Hike hike;
  const HikeCard({super.key, required this.hike});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final dateText =
        '${hike.hikeDate.day}/${hike.hikeDate.month}/${hike.hikeDate.year}';

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
      default:
        syncIcon = Icons.cloud_off_outlined;
        syncColor = Colors.grey;
        syncTooltip = 'Status tidak diketahui';
    }


    return Dismissible(
      key: ValueKey(hike.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
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
      onDismissed: (direction) {
        ref.read(hikeDaoProvider).softDeleteHike(hike.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${hike.mountainName} ditandai untuk dihapus.'),
            backgroundColor: Colors.red[800],
          ),
        );
      },
      child: InkWell(
        onTap: () {
          context.push('/home/hike_detail/${hike.id}');
        },
        borderRadius: BorderRadius.circular(16.0),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        context.push('/home/edit_hike', extra: hike);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // --- BARIS INFO (TANGGAL & DURASI) ---
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
                    
                    // --- PERBAIKAN TAMPILAN DURASI ---
                    if (hike.durationSeconds != null) ...[
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(hike.durationSeconds), // <-- Gunakan helper
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    // --- AKHIR PERBAIKAN ---
                  ],
                ),

                // ... (Sisa kode Anda untuk Partner & Notes tetap sama) ...
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
                if (hike.notes != null && hike.notes!.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(
                    hike.notes!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 3,
                    overflow:
                        TextOverflow.ellipsis,
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