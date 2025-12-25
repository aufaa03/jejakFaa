import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/database_providers.dart';
import 'package:jejak_faa_new/data/models/sync_status.dart';
import 'package:intl/intl.dart';

class HikeCard extends ConsumerWidget {
  final Hike hike;
  const HikeCard({super.key, required this.hike});

  // Warna sesuai palet Jejak Faa
  static const Color primaryColor = Color(0xFF1A535C);
  static const Color backgroundColor = Color(0xFFF7F7F2);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color accentColor = Color(0xFFE07A5F);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateText = DateFormat('dd MMM yyyy').format(hike.hikeDate);
    final syncConfig = _getSyncConfig(hike.syncStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.push('/home/hike_detail/${hike.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan mountain name dan actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mountain icon dengan background yang konsisten
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.terrain_rounded,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Title and info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hike.mountainName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          
                          // Sync status chip yang lebih refined
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: syncConfig.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: syncConfig.color.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  syncConfig.icon, 
                                  size: 14, 
                                  color: syncConfig.color
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  syncConfig.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: syncConfig.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // More options button
                    _buildOptionsButton(context, ref),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Stats row dengan layout yang lebih baik
                _buildStatsRow(dateText),
                
                // Additional info sections
                if (hike.partners != null && hike.partners!.isNotEmpty) 
                  _buildPartnersSection(),
                
                if (hike.notes != null && hike.notes!.isNotEmpty) 
                  _buildNotesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsButton(BuildContext context, WidgetRef ref) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(
          Icons.more_vert_rounded,
          color: textSecondary,
          size: 20,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: () {
          _showOptionsMenu(context, ref);
        },
      ),
    );
  }

  Widget _buildStatsRow(String dateText) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.calendar_today_outlined,
            value: dateText,
            color: primaryColor,
          ),
        ),
        if (hike.durationSeconds != null)
          Expanded(
            child: _buildStatItem(
              icon: Icons.timer_outlined,
              value: _formatDuration(hike.durationSeconds!),
              color: const Color(0xFF4ECDC4),
            ),
          ),
        if (hike.totalDistanceKm != null)
          Expanded(
            child: _buildStatItem(
              icon: Icons.terrain_outlined,
              value: '${hike.totalDistanceKm!.toStringAsFixed(1)} km',
              color: const Color(0xFFFFC107),
            ),
          ),
        if (hike.totalElevationGainMeters != null)
          Expanded(
            child: _buildStatItem(
              icon: Icons.arrow_upward_outlined,
              value: '${hike.totalElevationGainMeters!.toStringAsFixed(0)} m',
              color: accentColor,
            ),
          ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon, 
              size: 16, 
              color: color.withOpacity(0.8)
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Container(
          height: 2,
          width: 20,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  Widget _buildPartnersSection() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.people_outline,
                size: 16,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hike.partners!,
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: textLight.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.note_outlined,
                size: 16,
                color: textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hike.notes!,
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  SyncConfig _getSyncConfig(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return SyncConfig(
          icon: Icons.cloud_done_outlined,
          color: const Color(0xFF2E7D32),
          label: 'Tersinkron',
        );
      case SyncStatus.pending:
      case SyncStatus.pending_update:
        return SyncConfig(
          icon: Icons.cloud_upload_outlined,
          color: const Color(0xFF1565C0),
          label: 'Menunggu',
        );
      case SyncStatus.pending_update:
        return SyncConfig(
          icon: Icons.delete_outline,
          color: const Color(0xFFD32F2F),
          label: 'Akan Dihapus',
        );
      default:
        return SyncConfig(
          icon: Icons.cloud_off_outlined,
          color: textLight,
          label: 'Offline',
        );
    }
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}j ${minutes}m';
    }
    return '${minutes}m';
  }

  void _showOptionsMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: cardColor,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Options
                _buildMenuOption(
                  icon: Icons.edit_outlined,
                  title: 'Edit Jejak',
                  color: primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/home/edit_hike', extra: hike);
                  },
                ),
                _buildMenuOption(
                  icon: Icons.delete_outline,
                  title: 'Hapus Jejak',
                  color: accentColor,
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, ref);
                  },
                ),
                const SizedBox(height: 8),
                
                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: textLight.withOpacity(0.3)),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: textLight,
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      onTap: onTap,
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: cardColor,
        title: Text(
          'Hapus Jejak?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        content: Text(
          'Jejak "${hike.mountainName}" akan ditandai untuk dihapus. '
          'Data akan dihapus permanen saat sinkronisasi.',
          style: TextStyle(
            fontSize: 14,
            color: textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: textSecondary,
            ),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(hikeDaoProvider).softDeleteHike(hike.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${hike.mountainName}" ditandai untuk dihapus'),
                  backgroundColor: primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class SyncConfig {
  final IconData icon;
  final Color color;
  final String label;

  SyncConfig({required this.icon, required this.color, required this.label});
}