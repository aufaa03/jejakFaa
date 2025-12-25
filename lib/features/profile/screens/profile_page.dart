import 'dart:math'; // IMPORT BARU untuk log dan pow
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/features/auth/providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jejak_faa_new/features/profile/widgets/badge_card.dart';
import 'package:jejak_faa_new/features/settings/provider/cache_service_provider.dart';
import 'package:jejak_faa_new/features/profile/providers/profile_provider.dart';
import 'package:jejak_faa_new/features/profile/providers/profile_stats_provider.dart';
import 'package:jejak_faa_new/features/profile/providers/mountain_stats_provider.dart';
import 'package:jejak_faa_new/features/settings/provider/app_info_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:jejak_faa_new/main.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  // Warna sesuai spesifikasi
  static const Color primaryColor = Color(0xFF1A535C); // Hijau Hutan Dalam
  static const Color backgroundColor = Color(0xFFF7F7F2); // Krem Pucat
  static const Color cardColor = Color(0xFFFFFFFF); // Putih bersih
  static const Color accentColor = Color(0xFFE07A5F); // Oranye Terakota
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final cacheState = ref.watch(cacheServiceProvider);
    final profileAsync = ref.watch(profileNotifierProvider);
    final mountainStatsAsync = ref.watch(mountainStatsProvider);
    final statsAsync = ref.watch(profileStatsProvider);
    final appVersionAsync = ref.watch(appVersionProvider);
    
    final user = authState.value;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat profil',
                  style: TextStyle(
                    fontSize: 16,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$e',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (profile) {
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              // --- Header Profil ---
              _buildProfileHeader(context, profile, user),
              
              const SizedBox(height: 32),

              // --- Card Pencapaian Terbaik ---
              _buildAchievementsCard(context, statsAsync),
              
              const SizedBox(height: 24),

              // --- Section Lencana ---
              _buildBadgesSection(context, statsAsync),
              
              const SizedBox(height: 24),

              // --- Section Gunung Terfavorit ---
              _buildFavoriteMountainsSection(context, mountainStatsAsync),
              
              const SizedBox(height: 32),

              // --- Menu Aksi ---
              _buildActionMenu(context, cacheState, appVersionAsync, ref),
              
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic profile, dynamic user) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withOpacity(0.2),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: profile.photoUrl != null && profile.photoUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: profile.photoUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => _buildDefaultAvatar(profile),
                      )
                    : _buildDefaultAvatar(profile),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => context.push('/home/edit_profile'),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: backgroundColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: cardColor,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          profile.displayName ?? 'Nama Pengguna',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? 'email@example.com',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Jejak Anda, Data Anda',
            style: TextStyle(
              color: primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(dynamic profile) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Text(
          (profile.displayName ?? 'U').substring(0, 1).toUpperCase(),
          style: TextStyle(
            fontSize: 36,
            color: Colors.grey[400],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsCard(BuildContext context, AsyncValue<dynamic> statsAsync) {
    return statsAsync.when(
      loading: () => _buildCard(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      ),
      error: (e, st) => _buildCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.grey[400],
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Gagal memuat statistik',
                style: TextStyle(color: textSecondary),
              ),
            ],
          ),
        ),
      ),
      data: (stats) {
        if (stats.totalHikes == 0) {
          return _buildCard(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.landscape_outlined,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Mulai Petualangan Pertamamu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rekam pendakian pertama untuk melihat pencapaianmu',
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return _buildCard(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.emoji_events_outlined,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Pencapaian Terbaik',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildAchievementRow(
                  context,
                  icon: Icons.signpost_outlined,
                  label: 'Pendakian Terpanjang',
                  hike: stats.longestHike,
                  formatter: (hike) =>
                      '${hike.totalDistanceKm?.toStringAsFixed(1) ?? '0'} km (${hike.mountainName})',
                ),
                const SizedBox(height: 16),
                _buildAchievementRow(
                  context,
                  icon: Icons.filter_hdr_outlined,
                  label: 'Tanjakan Tertinggi',
                  hike: stats.highestClimbHike,
                  formatter: (hike) =>
                      '${hike.totalElevationGainMeters?.toStringAsFixed(0) ?? '0'} m (${hike.mountainName})',
                ),
                const SizedBox(height: 16),
                _buildAchievementRow(
                  context,
                  icon: Icons.watch_later_outlined,
                  label: 'Durasi Terlama',
                  hike: stats.longestDurationHike,
                  formatter: (hike) {
                    final duration = Duration(seconds: hike.durationSeconds ?? 0);
                    final days = duration.inDays;
                    final hours = duration.inHours.remainder(24);
                    return '${days > 0 ? '$days hari ' : ''}$hours jam (${hike.mountainName})';
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Hike? hike,
    required String Function(Hike) formatter,
  }) {
    String valueText;
    String detailText = '';

    if (hike != null) {
      final formatted = formatter(hike);
      final parts = formatted.split(' (');
      valueText = parts[0];
      if (parts.length > 1) {
        detailText = '(${parts[1]}';
      }
    } else {
      valueText = '-';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    valueText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                          fontSize: 16,
                        ),
                  ),
                  if (detailText.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        detailText,
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesSection(BuildContext context, AsyncValue<dynamic> statsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.workspace_premium_outlined,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Lencana',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: statsAsync.when(
            loading: () => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
            error: (e, st) => const SizedBox.shrink(),
            data: (stats) => ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: [
                const SizedBox(width: 4),
                BadgeCard(
                  title: '5 Puncak',
                  description: 'Selesaikan 5 pendakian',
                  icon: Icons.filter_hdr_outlined,
                  isUnlocked: (stats.totalHikes >= 5),
                  primaryColor: primaryColor,
                  accentColor: accentColor,
                ),
                BadgeCard(
                  title: '100km',
                  description: 'Capai total 100km jarak pendakian',
                  icon: Icons.trending_up,
                  isUnlocked: (stats.totalDistanceKm >= 100),
                  primaryColor: primaryColor,
                  accentColor: accentColor,
                ),
                BadgeCard(
                  title: 'Everest',
                  description: 'Capai 8.848m total tanjakan',
                  icon: Icons.landscape_outlined,
                  isUnlocked: (stats.totalElevationGainM >= 8848),
                  primaryColor: primaryColor,
                  accentColor: accentColor,
                ),
                BadgeCard(
                  title: '10 Puncak',
                  description: 'Selesaikan 10 pendakian',
                  icon: Icons.star_outline,
                  isUnlocked: (stats.totalHikes >= 10),
                  primaryColor: primaryColor,
                  accentColor: accentColor,
                ),
                BadgeCard(
                  title: 'Fotografer',
                  description: 'Upload 10 foto',
                  icon: Icons.camera_alt_outlined,
                  isUnlocked: false,
                  primaryColor: primaryColor,
                  accentColor: accentColor,
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteMountainsSection(BuildContext context, AsyncValue<List<dynamic>> mountainStatsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.landscape_outlined,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Gunung Terfavorit',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        mountainStatsAsync.when(
          loading: () => _buildCard(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          ),
          error: (e, st) => _buildCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Gagal memuat statistik gunung',
                style: TextStyle(color: textSecondary),
              ),
            ),
          ),
          data: (stats) {
            if (stats.isEmpty) {
              return _buildCard(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.landscape_outlined,
                        size: 48,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada data gunung',
                        style: TextStyle(
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final top3Stats = stats.take(3);

            return _buildCard(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: top3Stats.map((stat) {
                    final index = top3Stats.toList().indexOf(stat);
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getRankColor(index),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: cardColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        stat.mountainName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${stat.hikeCount} kali didaki • ${stat.totalDistanceKm.toStringAsFixed(1)} km',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${stat.hikeCount}x',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionMenu(BuildContext context, AsyncValue<int> cacheState, 
      AsyncValue<String> appVersionAsync, WidgetRef ref) {
    return _buildCard(
      child: Column(
        children: [
          _buildMenuTile(
            icon: Icons.person_outline,
            title: 'Edit Profil',
            onTap: () => context.push('/home/edit_profile'),
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.storage_outlined,
            title: 'Cache Peta Offline',
            subtitle: cacheState.when(
              data: (sizeInBytes) => Text('Ukuran saat ini: ${_formatBytes(sizeInBytes)}'),
              error: (e, st) => const Text(
                'Gagal menghitung cache',
                style: TextStyle(color: Colors.red),
              ),
              loading: () => const Text('Menghitung...'),
            ),
            trailing: cacheState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: Icon(Icons.delete_outline, color: accentColor),
                    onPressed: () => ref.read(cacheServiceProvider.notifier).clearCache(),
                  ),
            onTap: () {}, // Tambahkan onTap kosong
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.feedback_outlined,
            title: 'Kirim Masukan',
            onTap: _sendFeedback,
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.code_outlined,
            title: 'Dibuat oleh',
            subtitle: Text(
              'Muhammad Aufa Rozaky',
              style: TextStyle(color: textSecondary),
            ),
            onTap: () => _launchURL('https://github.com/aufaa03'),
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.logout,
            title: 'Keluar',
            titleColor: accentColor,
            iconColor: accentColor,
            onTap: () => ref.read(authControllerProvider).signOut(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    Widget? subtitle,
    Widget? trailing,
    Color? titleColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? primaryColor,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle,
      trailing: trailing ?? Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Colors.grey[200],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0: return const Color(0xFFFFD700); // Emas
      case 1: return const Color(0xFFC0C0C0); // Perak
      case 2: return const Color(0xFFCD7F32); // Perunggu
      default: return primaryColor;
    }
  }

  Future<void> _sendFeedback() async {
    final email = Uri(
      scheme: 'mailto',
      path: 'aufaa208@gmail.com',
      query: 'subject=Masukan Aplikasi Jejak Faa',
    );
    if (await canLaunchUrl(email)) {
      await launchUrl(email);
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // Method untuk format bytes
  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }
}