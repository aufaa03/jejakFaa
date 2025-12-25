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
    final authState = ref.watch(authStateProvider);
    final userName = authState.value?.name?.split(' ').first ?? 'Pendaki';
    
    final syncState = ref.watch(syncProvider);
    final pendingCount = ref.watch(pendingHikesCountProvider);
    final hikeListAsync = ref.watch(hikeListStreamProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: CustomScrollView(
        slivers: [
          // Header dengan expanded height
          SliverAppBar(
            expandedHeight: 180,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A535C),
                      Color(0xFF2D7A83),
                    ],
                  ),
                ),
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 32,
                  top: 70,
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama user
                      Text(
                        'Halo, $userName 👋',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Jejak Anda, Data Anda',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content dengan safe area
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Sync Status Card
                _buildSyncStatusCard(context, syncState, pendingCount),
                
                const SizedBox(height: 24),
                
                // Statistics Cards Grid
                _buildStatsGrid(context, ref),
                
                const SizedBox(height: 32),
                
                // Recent Hikes Section
                _buildRecentHikesSection(context, hikeListAsync),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 56,
      width: 56,
      child: FloatingActionButton(
        onPressed: () {
          // Navigate to tracking page
          // context.push('/tracking');
        },
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.navigation_outlined, size: 24),
      ),
    );
  }

  Widget _buildSyncStatusCard(BuildContext context, 
      AsyncValue<void> syncState, AsyncValue<int> pendingCount) {
    Widget content;
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String title, subtitle;

    if (syncState.isLoading) {
      backgroundColor = primaryColor.withOpacity(0.1);
      textColor = primaryColor;
      icon = Icons.cloud_sync_outlined;
      title = 'Sinkronisasi...';
      subtitle = 'Menyimpan jejak terbaru...';
    } else if (pendingCount.valueOrNull != null && pendingCount.value! > 0) {
      backgroundColor = const Color(0xFFFFF3E0);
      textColor = const Color(0xFFEF6C00);
      icon = Icons.schedule_outlined;
      title = '${pendingCount.value} Jejak Tertunda';
      subtitle = 'Data akan disinkron saat koneksi stabil';
    } else {
      backgroundColor = const Color(0xFFE8F5E8);
      textColor = const Color(0xFF2E7D32);
      icon = Icons.cloud_done_outlined;
      title = 'Semua Jejak Aman';
      subtitle = 'Data Anda sudah tersinkronisasi';
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: textColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: textColor.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (syncState.isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, WidgetRef ref) {
    final totalHikes = ref.watch(hikeListStreamProvider).valueOrNull?.length ?? 0;
    final totalDistance = _calculateTotalDistance(ref);
    final totalElevation = _calculateTotalElevation(ref);
    final totalDuration = _calculateTotalDuration(ref);

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      children: [
        _buildStatCard(
          value: totalHikes.toString(),
          label: 'Total Jejak',
          icon: Icons.flag_outlined,
          color: primaryColor,
        ),
        _buildStatCard(
          value: '${totalDistance.toStringAsFixed(1)} km',
          label: 'Total Jarak',
          icon: Icons.terrain_outlined,
          color: const Color(0xFF4ECDC4),
        ),
        _buildStatCard(
          value: '${totalElevation.toStringAsFixed(0)} m',
          label: 'Total Elevasi',
          icon: Icons.arrow_upward_outlined,
          color: const Color(0xFFFFC107),
        ),
        _buildStatCard(
          value: totalDuration,
          label: 'Total Durasi',
          icon: Icons.timer_outlined,
          color: accentColor,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHikesSection(BuildContext context, AsyncValue<List<Hike>> hikeListAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pendakian Terakhir',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to full hike list
                // context.push('/hikes');
              },
              child: Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        hikeListAsync.when(
          loading: () => _buildLoadingHikes(),
          error: (err, stack) => _buildErrorState(err.toString()),
          data: (hikes) {
            if (hikes.isEmpty) {
              return _buildEmptyState();
            }
            final recentHikes = hikes.take(3).toList();
            return Column(
              children: recentHikes.map((hike) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: HikeCard(hike: hike),
                )
              ).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingHikes() {
    return Column(
      children: List.generate(3, (index) => _buildHikeCardSkeleton()),
    );
  }

  Widget _buildHikeCardSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline, 
            size: 48, 
            color: textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.length > 60 ? '${error.substring(0, 60)}...' : error,
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Retry logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.terrain_outlined, 
            size: 64, 
            color: textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Pendakian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai petualangan pertama Anda dan rekam jejaknya',
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to tracking
              // context.push('/tracking');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Mulai Tracking'),
          ),
        ],
      ),
    );
  }

  // Helper methods untuk kalkulasi statistik
  double _calculateTotalDistance(WidgetRef ref) {
    final hikes = ref.watch(hikeListStreamProvider).valueOrNull ?? [];
    return hikes.fold(0.0, (sum, hike) => sum + (hike.totalDistanceKm ?? 0));
  }

  double _calculateTotalElevation(WidgetRef ref) {
    final hikes = ref.watch(hikeListStreamProvider).valueOrNull ?? [];
    return hikes.fold(0.0, (sum, hike) => sum + (hike.totalElevationGainMeters ?? 0));
  }

  String _calculateTotalDuration(WidgetRef ref) {
    final hikes = ref.watch(hikeListStreamProvider).valueOrNull ?? [];
    final totalSeconds = hikes.fold(0, (sum, hike) => sum + (hike.durationSeconds ?? 0));
    final hours = totalSeconds ~/ 3600;
    final days = hours ~/ 24;
    
    if (days > 0) {
      return '${days}h ${hours % 24}j';
    } else {
      return '${hours}j';
    }
  }
}