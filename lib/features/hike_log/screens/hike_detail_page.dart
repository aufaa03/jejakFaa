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
  // Mode edit sudah dihapus, kita hanya butuh state untuk upload foto
  bool _isUploading = false;

  // --- SEMUA FUNGSI EDIT (initState, dispose, _loadFormData, _saveChanges) DIHAPUS ---

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Ambil Foto (Kamera)'),
            onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Pilih dari Galeri'),
            onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
          ),
        ],
      ),
    );
    if (source == null) return; 
    
    final XFile? imageFile;
    try {
      imageFile = await imagePicker.pickImage(source: source, imageQuality: 80);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil gambar: $e'), backgroundColor: Colors.red)
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
          const SnackBar(
            content: Text('Foto berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload foto: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Jejak'),
        actions: [
          // Navigasi ke Halaman Form
          hikeDetailAsync.whenData((hike) {
            if (hike == null) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Jejak Ini',
              onPressed: () {
                // Gunakan 'push' agar kembali ke halaman ini
                context.push('/home/edit_hike', extra: hike);
              },
            );
          }).value ?? const SizedBox.shrink()
        ],
      ),
      body: hikeDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (hike) {
          if (hike == null) {
            return const Center(child: Text('Data pendakian tidak ditemukan.'));
          }

          final dateText =
              '${hike.hikeDate.day}/${hike.hikeDate.month}/${hike.hikeDate.year}';

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                hike.mountainName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.calendar_today_outlined,
                        'Tanggal',
                        dateText,
                      ),
                      
                      // --- PERBAIKAN TAMPILAN DURASI ---
                      if (hike.durationSeconds != null) ...[
                        const Divider(height: 16),
                        _buildInfoRow(
                          Icons.timer_outlined,
                          'Durasi',
                          _formatDuration(hike.durationSeconds!), 
                        ),
                      ],
                      // --- AKHIR PERBAIKAN ---

                      if (hike.totalDistanceKm != null) ...[
                        const Divider(height: 16),
                        _buildInfoRow(
                          Icons.straighten_outlined,
                          'Jarak',
                          '${hike.totalDistanceKm?.toStringAsFixed(2)} km',
                        ),
                      ],
                      if (hike.totalElevationGainMeters != null) ...[
                        const Divider(height: 16),
                        _buildInfoRow(
                          Icons.trending_up_outlined,
                          'Tanjakan',
                          '${hike.totalElevationGainMeters?.toStringAsFixed(0)} m',
                        ),
                      ],
                      if (hike.totalElevationLossMeters != null && hike.totalElevationLossMeters! > 0) ...[
                        const Divider(height: 16),
                        _buildInfoRow(
                          Icons.trending_down_outlined,
                          'Turunan',
                          '${hike.totalElevationLossMeters?.toStringAsFixed(0)} m',
                        ),
                      ],

                      // --- PERBAIKAN TAMPILAN PACE ---
                      if (hike.averagePaceMinPerKm != null && hike.averagePaceMinPerKm! > 0) ...[
                        const Divider(height: 16),
                        _buildInfoRow(
                          Icons.speed_outlined,
                          'Pace Rata-rata', // Label baru
                          '${hike.averagePaceMinPerKm?.toStringAsFixed(2)} mnt/km', // Data baru
                        ),
                      ],
                      // --- AKHIR PERBAIKAN ---

                      if (hike.maxSpeedKmh != null && hike.maxSpeedKmh! > 0) ...[
                        const Divider(height: 16),
                        _buildInfoRow(
                          Icons.rocket_launch_outlined,
                          'Maksimal',
                          '${hike.maxSpeedKmh?.toStringAsFixed(1)} km/j',
                        ),
                      ],
                      if (hike.partners != null &&
                          hike.partners!.isNotEmpty) ...[
                        const Divider(height: 16),
                        _buildInfoRow(Icons.people_outline, 'Partner', hike.partners!),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text('Peta Rute 🗺️', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              _buildRouteMap(context, ref, widget.localHikeId),
              
              const SizedBox(height: 24),
              if (hike.notes != null && hike.notes!.isNotEmpty) ...[
                Text('Catatan Perjalanan ✍️', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  hike.notes!,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 24),
              ],
              
              Text('Galeri Jejak 📸', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              _buildPhotoGallery(context, ref, widget.localHikeId),
              
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isUploading ? null : _pickImage,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(_isUploading ? 'Mengupload...' : 'Tambah Foto'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- SEMUA FUNGSI HELPER DISPLAY DI BAWAH INI TETAP DISIMPAN ---
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Text('$label:', style: TextStyle(color: Colors.grey[700])),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  static IconData _getIconForCategory(String? category) {
    switch (category) {
      case 'POS': return Icons.signpost_outlined;
      case 'SUMBER_AIR': return Icons.water_drop_outlined;
      case 'PUNCAK': return Icons.flag_outlined;
      case 'CAMP': return Icons.cabin_sharp;
      default: return Icons.location_pin;
    }
  }

  void _showWaypointDetails(
    BuildContext context,
    WidgetRef ref,
    HikeWaypoint waypoint,
  ) {
    final theme = Theme.of(context);
    final numberFormat = NumberFormat.decimalPattern('id'); 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.white, // Pastikan background putih
      builder: (ctx) {
        return Consumer(
          builder: (context, modalRef, child) {
            
            final photo = modalRef.watch(waypointPhotoProvider(
              hikeId: waypoint.hikeId, 
              waypointId: waypoint.id
            ));

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(_getIconForCategory(waypoint.category), size: 32, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(waypoint.name, style: theme.textTheme.headlineSmall),
                            if(waypoint.category != null)
                              Text(
                                waypoint.category!,
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  
                  if(waypoint.description != null && waypoint.description!.isNotEmpty) ...[
                    const Divider(height: 24),
                    Text(waypoint.description!, style: theme.textTheme.bodyLarge),
                  ],

                  if(photo != null) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        photo.photoUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],

                  const Divider(height: 24),
                  Text("Statistik", style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if(waypoint.altitude != null)
                        _buildStatColumn(
                          context, 
                          numberFormat.format(waypoint.altitude), 
                          'mdpl'
                        ),
                      if(waypoint.elevationGainToHere != null)
                        _buildStatColumn(
                          context, 
                          '+${numberFormat.format(waypoint.elevationGainToHere)}', 
                          'm Naik'
                        ),
                      if(waypoint.elevationLossToHere != null)
                        _buildStatColumn(
                          context, 
                          '-${numberFormat.format(waypoint.elevationLossToHere)}', 
                          'm Turun'
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildRouteMap(BuildContext context, WidgetRef ref, int hikeId) {
    // ... (Fungsi ini 100% sudah benar) ...
    final routePointsAsync = ref.watch(routePointsProvider(hikeId));
    final waypointsAsync = ref.watch(hikeWaypointsProvider(hikeId));

    return routePointsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(
        child: Text('Gagal memuat rute: $e', style: const TextStyle(color: Colors.red)),
      ),
      data: (points) {
        if (points.isEmpty) {
          return Container( height: 200, alignment: Alignment.center, decoration: BoxDecoration( color: Colors.grey[100], borderRadius: BorderRadius.circular(12.0), border: Border.all(color: Colors.grey[300]!), ), child: Text( 'Rute GPS tidak terekam untuk pendakian ini.', style: TextStyle(color: Colors.grey[600]), ), );
        }

        final List<LatLng> polylinePoints = points
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();
        final bounds = LatLngBounds.fromPoints(polylinePoints);

        final List<Marker> markers = waypointsAsync.maybeWhen(
          data: (waypoints) => waypoints
              .map(
                (wp) => Marker(
                  width: 40.0,
                  height: 40.0,
                  point: LatLng(wp.latitude, wp.longitude),
                  child: IconButton(
                    icon: Icon(_getIconForCategory(wp.category),
                        color: Colors.purple.shade700, size: 35),
                    tooltip: wp.name,
                    onPressed: () {
                      _showWaypointDetails(context, ref, wp);
                    },
                  ),
                ),
              )
              .toList(),
          orElse: () => [],
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            height: 300,
            color: Colors.grey[200],
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
                      color: Colors.blue,
                      strokeWidth: 4,
                    ),
                  ],
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPhotoGallery(BuildContext context, WidgetRef ref, int hikeId) {
    // ... (Fungsi ini 100% sudah benar) ...
    final photosAsync = ref.watch(hikePhotosProvider(hikeId));
    return photosAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, s) => Center(
        child: Text('Gagal memuat foto: $e', style: const TextStyle(color: Colors.red)),
      ),
      data: (photos) {
        
        final generalPhotos = photos.where((p) => p.waypointId == null).toList();

        if (generalPhotos.isEmpty) { 
          return Center(
            child: Text('Belum ada foto.', style: TextStyle(color: Colors.grey[600])),
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
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    photo.photoUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.broken_image_outlined,
                            color: Colors.grey[400]),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildStatColumn(BuildContext context, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatDuration(int totalSeconds) {
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
    if (hours == 0) { // Hanya tampilkan detik jika < 1 jam
      parts.add('${seconds}d');
    }
  	if (parts.isEmpty && totalSeconds == 0) {
      return '0d';
    }

    return parts.join(' ');
  }
}