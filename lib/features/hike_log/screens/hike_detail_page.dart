import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jejak_faa_new/data/local_db/database.dart';
import 'package:jejak_faa_new/data/local_db/database_providers.dart';
import 'package:jejak_faa_new/data/models/sync_status.dart';
import 'package:jejak_faa_new/features/auth/providers/auth_provider.dart';
import 'package:drift/drift.dart' as d;
import 'package:image_picker/image_picker.dart';
import 'package:jejak_faa_new/features/hike_log/providers/hike_photo_provider.dart';
import 'package:jejak_faa_new/features/gallery/screens/photo_detail_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:jejak_faa_new/features/hike_log/providers/route_points_provider.dart';
import 'package:jejak_faa_new/features/hike_log/providers/hike_waypoints_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jejak_faa_new/features/hike_log/widgets/hike_stats_chart.dart';

part 'hike_detail_page.g.dart';

@riverpod
Future<Hike?> hikeDetail(HikeDetailRef ref, int localHikeId) {
  final dao = ref.watch(hikeDaoProvider);
  return dao.getHikeById(localHikeId);
}

@riverpod
HikePhoto? waypointPhoto(
  WaypointPhotoRef ref, {
  required int hikeId,
  required int waypointId,
}) {
  final photosAsync = ref.watch(hikePhotosProvider(hikeId));
  final photos = photosAsync.valueOrNull ?? [];
  try {
    return photos.firstWhere((p) => p.waypointId == waypointId);
  } catch (e) {
    return null;
  }
}

class HikeDetailPage extends ConsumerStatefulWidget {
  final int localHikeId;
  const HikeDetailPage({super.key, required this.localHikeId});

  @override
  ConsumerState<HikeDetailPage> createState() => _HikeDetailPageState();
}

class _HikeDetailPageState extends ConsumerState<HikeDetailPage> {
  bool _isUploading = false;

  // Warna sesuai palet Jejak Faa
  static const Color primaryColor = Color(0xFF1A535C);
  static const Color backgroundColor = Color(0xFFF7F7F2);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color accentColor = Color(0xFFE07A5F);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  'Tambah Foto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Camera option
                _buildImageSourceOption(
                  icon: Icons.camera_alt_rounded,
                  title: 'Ambil Foto',
                  subtitle: 'Gunakan kamera',
                  onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
                ),
                
                // Gallery option
                _buildImageSourceOption(
                  icon: Icons.photo_library_rounded,
                  title: 'Pilih dari Galeri',
                  subtitle: 'Pilih foto yang sudah ada',
                  onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
                ),
                
                const SizedBox(height: 8),
                
                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
    
    if (source == null) return;

    final XFile? imageFile;
    try {
      imageFile = await imagePicker.pickImage(source: source, imageQuality: 85);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil gambar: $e'),
            backgroundColor: accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return;
    }

    if (imageFile == null) return;

    setState(() => _isUploading = true);
    try {
      final userId = ref.read(authStateProvider).value!.id;
      final photoUrl = await _uploadToStorage(imageFile, userId);

      final photoEntry = HikePhotosCompanion(
        hikeId: d.Value(widget.localHikeId),
        photoUrl: d.Value(photoUrl),
        syncStatus: const d.Value(SyncStatus.pending),
        waypointId: const d.Value(null),
      );
      await ref.read(hikePhotoDaoProvider).insertHikePhoto(photoEntry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Foto berhasil ditambahkan!'),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload foto: $e'),
            backgroundColor: accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: primaryColor, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: textSecondary,
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

  Future<String> _uploadToStorage(XFile imageFile, String userId) async {
    final file = File(imageFile.path);
    final fileExtension = imageFile.path.split('.').last.toLowerCase();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    final path = '$userId/${widget.localHikeId}/$fileName';
    await Supabase.instance.client.storage
        .from('hike_photos')
        .upload(path, file);
    final publicUrl = Supabase.instance.client.storage
        .from('hike_photos')
        .getPublicUrl(path);
    return publicUrl;
  }

  @override
  Widget build(BuildContext context) {
    final hikeDetailAsync = ref.watch(hikeDetailProvider(widget.localHikeId));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: primaryColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detail Jejak',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        actions: [
          hikeDetailAsync.whenData((hike) {
                if (hike == null) return const SizedBox.shrink();
                return IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: primaryColor,
                  ),
                  tooltip: 'Edit Jejak',
                  onPressed: () {
                    context.push('/home/edit_hike', extra: hike);
                  },
                );
              }).value ??
              const SizedBox.shrink(),
        ],
      ),
      body: hikeDetailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Gagal memuat data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  err.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(hikeDetailProvider(widget.localHikeId));
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
        ),
        data: (hike) {
          if (hike == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      Icons.terrain_outlined,
                      size: 40,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Data tidak ditemukan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }

          final dateText = DateFormat(
            'dd MMMM yyyy',
            'id_ID',
          ).format(hike.hikeDate);
          final routePointsAsync = ref.watch(
            routePointsProvider(widget.localHikeId),
          );

          return CustomScrollView(
            slivers: [
              // Header Section
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, const Color(0xFF2D7A83)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hike.mountainName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dateText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Jejak Anda, Data Anda',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stats Grid Section
              SliverToBoxAdapter(child: _buildStatsGrid(hike)),

              // Charts Section
              SliverToBoxAdapter(
                child: _buildChartsSection(routePointsAsync, hike.id),
              ),

              // Map Section
              SliverToBoxAdapter(
                child: _buildMapSection(context, ref, widget.localHikeId),
              ),

              // Notes Section
              if (hike.notes != null && hike.notes!.isNotEmpty)
                SliverToBoxAdapter(child: _buildNotesSection(hike.notes!)),

              // Gallery Section
              SliverToBoxAdapter(
                child: _buildGallerySection(context, ref, widget.localHikeId),
              ),

              // Add Photo Button
              SliverToBoxAdapter(child: _buildAddPhotoButton()),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(Hike hike) {
    return Container(
      margin: const EdgeInsets.all(24),
      child: GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
        ),
        children: [
          _buildStatCard(
            value: hike.durationSeconds != null
                ? _formatDuration(hike.durationSeconds!)
                : '-',
            label: 'Durasi',
            icon: Icons.timer_outlined,
            color: primaryColor,
          ),
          _buildStatCard(
            value: hike.totalDistanceKm != null
                ? '${hike.totalDistanceKm!.toStringAsFixed(1)} km'
                : '-',
            label: 'Jarak',
            icon: Icons.terrain_outlined,
            color: const Color(0xFF4ECDC4),
          ),
          _buildStatCard(
            value: hike.totalElevationGainMeters != null
                ? '${hike.totalElevationGainMeters!.toStringAsFixed(0)} m'
                : '-',
            label: 'Tanjakan',
            icon: Icons.arrow_upward_outlined,
            color: const Color(0xFFFFC107),
          ),
          _buildStatCard(
            value:
                hike.averagePaceMinPerKm != null &&
                    hike.averagePaceMinPerKm! > 0
                ? '${hike.averagePaceMinPerKm!.toStringAsFixed(1)} mnt/km'
                : '-',
            label: 'Pace Rata-rata',
            icon: Icons.speed_outlined,
            color: accentColor,
          ),
          if (hike.maxSpeedKmh != null && hike.maxSpeedKmh! > 0)
            _buildStatCard(
              value: '${hike.maxSpeedKmh!.toStringAsFixed(1)} km/j',
              label: 'Kecepatan Maks',
              icon: Icons.rocket_launch_outlined,
              color: const Color(0xFF9C27B0),
            ),
          if (hike.startTemperature != null)
            _buildStatCard(
              value: '${hike.startTemperature!.toStringAsFixed(0)}°C',
              label: 'Suhu Awal',
              icon: Icons.thermostat_outlined,
              color: const Color(0xFF2196F3),
            ),
        ],
      ),
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
            offset: const Offset(0, 5),
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
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(
    AsyncValue<List<RoutePoint>> routePointsAsync,
    int hikeId,
  ) {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Grafik Performa',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          routePointsAsync.when(
            loading: () => Container(
              height: 200,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
            ),
            error: (e, s) => Container(
              height: 100,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'Gagal memuat grafik',
                  style: TextStyle(color: textSecondary),
                ),
              ),
            ),
            data: (points) {
              if (points.isEmpty) {
                return Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 32,
                          color: textLight,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tidak ada data GPS',
                          style: TextStyle(color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Container(
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
                child: HikeStatsChart(hikeId: hikeId),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(BuildContext context, WidgetRef ref, int hikeId) {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Peta Rute',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildRouteMapContent(context, ref, hikeId),
        ],
      ),
    );
  }

  Widget _buildRouteMapContent(
    BuildContext context,
    WidgetRef ref,
    int hikeId,
  ) {
    final routePointsAsync = ref.watch(routePointsProvider(hikeId));
    final waypointsAsync = ref.watch(hikeWaypointsProvider(hikeId));

    return routePointsAsync.when(
      loading: () => Container(
        height: 300,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      ),
      error: (e, s) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                size: 48,
                color: textLight,
              ),
              const SizedBox(height: 12),
              Text(
                'Gagal memuat peta',
                style: TextStyle(color: textSecondary),
              ),
            ],
          ),
        ),
      ),
      data: (points) {
        if (points.isEmpty) {
          return Container(
            height: 300,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 48,
                    color: textLight,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tidak ada data rute',
                    style: TextStyle(color: textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        final List<LatLng> polylinePoints = points
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();
        final bounds = LatLngBounds.fromPoints(polylinePoints);

        final startPoint = polylinePoints.isNotEmpty ? polylinePoints.first : null;
        final finishPoint = polylinePoints.isNotEmpty ? polylinePoints.last : null;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: FlutterMap(
              options: MapOptions(
                initialCameraFit: CameraFit.bounds(
                  bounds: bounds,
                  padding: const EdgeInsets.all(25.0),
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.jejak_faa_new',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinePoints,
                      color: primaryColor,
                      strokeWidth: 4,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: _buildMapMarkers(
                    startPoint: startPoint,
                    finishPoint: finishPoint,
                    waypoints: waypointsAsync.valueOrNull ?? [],
                    ref: ref,
                    hikeId: hikeId,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Marker> _buildMapMarkers({
    required LatLng? startPoint,
    required LatLng? finishPoint,
    required List<HikeWaypoint> waypoints,
    required WidgetRef ref,
    required int hikeId,
  }) {
    final List<Marker> markers = [];

    // Start Marker
    if (startPoint != null) {
      markers.add(
        Marker(
          width: 48.0,
          height: 48.0,
          point: startPoint,
          child: Tooltip(
            message: 'Titik Mulai',
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Finish Marker
    if (finishPoint != null) {
      markers.add(
        Marker(
          width: 48.0,
          height: 48.0,
          point: finishPoint,
          child: Tooltip(
            message: 'Titik Selesai',
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Waypoint Markers
    markers.addAll(
      waypoints.map((waypoint) {
        return Marker(
          width: 48.0,
          height: 48.0,
          point: LatLng(waypoint.latitude, waypoint.longitude),
          child: Tooltip(
            message: waypoint.name,
            child: GestureDetector(
              onTap: () {
                _showWaypointDetails(context, ref, waypoint);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForCategory(waypoint.category),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );

    return markers;
  }

  void _showWaypointDetails(
    BuildContext context,
    WidgetRef ref,
    HikeWaypoint waypoint,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconForCategory(waypoint.category),
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            waypoint.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          if (waypoint.category != null)
                            Text(
                              waypoint.category!,
                              style: TextStyle(
                                fontSize: 16,
                                color: textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20, color: textSecondary),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                
                if (waypoint.description != null && waypoint.description!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    waypoint.description!,
                    style: TextStyle(
                      fontSize: 16,
                      color: textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesSection(String notes) {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Catatan Perjalanan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Text(
              notes,
              style: TextStyle(
                fontSize: 16,
                color: textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection(BuildContext context, WidgetRef ref, int hikeId) {
    final photosAsync = ref.watch(hikePhotosProvider(hikeId));

    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Galeri Jejak',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          photosAsync.when(
            loading: () => Container(
              height: 120,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
            ),
            error: (e, s) => Container(
              height: 100,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'Gagal memuat foto',
                  style: TextStyle(color: textSecondary),
                ),
              ),
            ),
            data: (photos) {
              final generalPhotos = photos
                  .where((p) => p.waypointId == null)
                  .toList();

              if (generalPhotos.isEmpty) {
                return Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 32,
                          color: textLight,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada foto',
                          style: TextStyle(color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemCount: generalPhotos.length,
                itemBuilder: (context, index) {
                  final photo = generalPhotos[index];
                  final heroTag = 'hike-photo-${photo.id}';

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => PhotoDetailPage(
                            photo: photo,
                            photoUrl: photo.photoUrl,
                            heroTag: heroTag,
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: heroTag,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          photo.photoUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: backgroundColor,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: backgroundColor,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: textLight,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isUploading ? null : _pickImage,
          icon: _isUploading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.add_photo_alternate_outlined),
          label: Text(_isUploading ? 'Mengupload...' : 'Tambah Foto'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
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

  IconData _getIconForCategory(String? category) {
    switch (category) {
      case 'POS':
        return Icons.signpost_outlined;
      case 'SUMBER_AIR':
        return Icons.water_drop_outlined;
      case 'PUNCAK':
        return Icons.flag_outlined;
      case 'CAMP':
        return Icons.cabin_outlined;
      default:
        return Icons.location_pin;
    }
  }
}