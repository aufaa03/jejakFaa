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
// --- 1. TAMBAHAN IMPORT UNTUK FORMAT ANGKA ---
import 'package:intl/intl.dart';

part 'hike_detail_page.g.dart';

@riverpod
Future<Hike?> hikeDetail(HikeDetailRef ref, int localHikeId) {
  final dao = ref.watch(hikeDaoProvider);
  return dao.getHikeById(localHikeId);
}

// --- 2. TAMBAHKAN PROVIDER BARU UNTUK FOTO WAYPOINT ---
/// Provider ini akan mengambil DAFTAR SEMUA FOTO untuk sebuah pendakian,
/// lalu mencari satu foto yang cocok dengan `waypointId` yang diberikan.
@riverpod
HikePhoto? waypointPhoto(WaypointPhotoRef ref, {
  required int hikeId, 
  required int waypointId
}) {
  // Kita tonton provider utama yang berisi SEMUA foto untuk pendakian ini
  final photosAsync = ref.watch(hikePhotosProvider(hikeId));
  // Ambil datanya jika ada
  final photos = photosAsync.valueOrNull ?? [];
  try {
    // Cari satu foto yang 'waypointId'-nya cocok
    return photos.firstWhere((p) => p.waypointId == waypointId);
  } catch (e) {
    return null; // Kembalikan null jika tidak ada foto yang cocok
  }
}
// --- AKHIR TAMBAHAN PROVIDER ---


class HikeDetailPage extends ConsumerStatefulWidget {
  final int localHikeId;

  const HikeDetailPage({super.key, required this.localHikeId});

  @override
  ConsumerState<HikeDetailPage> createState() => _HikeDetailPageState();
}

class _HikeDetailPageState extends ConsumerState<HikeDetailPage> {
  // ... (Semua state Anda: _isEditing, _isSaving, _isUploading) ...
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isUploading = false;

  // ... (Semua controller Anda) ...
  late TextEditingController _mountainNameController;
  late TextEditingController _durationController;
  late TextEditingController _distanceController;
  late TextEditingController _elevationController;
  late TextEditingController _partnersController;
  late TextEditingController _notesController;
  DateTime? _selectedDate;

  // ... (initState, dispose, _loadFormData, _pickDate tetap sama) ...
  @override
  void initState() {
    super.initState();
    _mountainNameController = TextEditingController();
    _durationController = TextEditingController();
    _distanceController = TextEditingController();
    _elevationController = TextEditingController();
    _partnersController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _mountainNameController.dispose();
    _durationController.dispose();
    _distanceController.dispose();
    _elevationController.dispose();
    _partnersController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadFormData(Hike hike) {
    _mountainNameController.text = hike.mountainName;
    _selectedDate = hike.hikeDate;
    _durationController.text = hike.durationMinutes?.toString() ?? '';
    _distanceController.text = hike.totalDistanceKm?.toStringAsFixed(2) ?? '';
    _elevationController.text = hike.totalElevationGainMeters?.toStringAsFixed(0) ?? '';
    _partnersController.text = hike.partners ?? '';
    _notesController.text = hike.notes ?? '';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }


  // --- 3. UPGRADE FUNGSI _pickImage (Konsisten dengan MapPage) ---
  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();

    // 1. Tampilkan dialog pilihan
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
    if (source == null) return; // User membatalkan

    // 2. Ambil gambar
    final XFile? imageFile;
    try {
      imageFile = await imagePicker.pickImage(
        source: source, imageQuality: 80,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil gambar: $e'), backgroundColor: Colors.red)
        );
      }
      return;
    }
    
    if (imageFile == null) return;

    // 3. Upload dan Simpan (Logika lama Anda sudah benar)
    setState(() => _isUploading = true);
    try {
      final userId = ref.read(authStateProvider).value!.id;
      final photoUrl = await _uploadToStorage(imageFile, userId);
      
      // Simpan sebagai foto "Umum" (waypointId tetap null)
      final photoEntry = HikePhotosCompanion(
        hikeId: d.Value(widget.localHikeId),
        photoUrl: d.Value(photoUrl),
        syncStatus: const d.Value(SyncStatus.pending),
        waypointId: const d.Value(null), // <-- Eksplisit null
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
  // --- AKHIR UPGRADE _pickImage ---

  // ... (_uploadToStorage dan _saveChanges tetap sama) ...
  Future<String> _uploadToStorage(XFile imageFile, String userId) async {
    final file = File(imageFile.path);
    final fileExtension = imageFile.path.split('.').last.toLowerCase();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    final path = '$userId/${widget.localHikeId}/$fileName';
    await Supabase.instance.client.storage.from('hike_photos').upload(path, file);
    final publicUrl =
        Supabase.instance.client.storage.from('hike_photos').getPublicUrl(path);
    return publicUrl;
  }
  
  Future<void> _saveChanges(Hike hike) async {
    // ... (Logika _saveChanges Anda sudah benar, tidak perlu diubah) ...
    if (_mountainNameController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama gunung & Tanggal wajib diisi')),
      );
      return;
    }
    final int? duration = int.tryParse(_durationController.text);
    final double? distance = double.tryParse(_distanceController.text);
    final double? elevation = double.tryParse(_elevationController.text);
    setState(() => _isSaving = true);
    try {
      final hikeEntry = HikesCompanion(
        id: d.Value(widget.localHikeId),
        userId: d.Value(hike.userId),
        mountainName: d.Value(_mountainNameController.text),
        hikeDate: d.Value(_selectedDate!),
        durationMinutes: d.Value(duration),
        totalDistanceKm: d.Value(distance ?? hike.totalDistanceKm),
        totalElevationGainMeters: d.Value(elevation ?? hike.totalElevationGainMeters),
        partners: d.Value(
          _partnersController.text.isEmpty ? null : _partnersController.text,
        ),
        notes: d.Value(_notesController.text.isEmpty ? null : _notesController.text),
        syncStatus: const d.Value(SyncStatus.pending_update),
      );
      await ref.read(hikeDaoProvider).updateHike(hikeEntry);
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data jejak berhasil disimpan')),
        );
        ref.refresh(hikeDetailProvider(widget.localHikeId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // ... (AppBar dan body setup tetap sama) ...
    final hikeDetailAsync = ref.watch(hikeDetailProvider(widget.localHikeId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Jejak'),
        actions: [
          if (!_isEditing)
            hikeDetailAsync.whenData(
              (hike) {
                if (hike == null) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit Jejak Ini',
                  onPressed: () {
                    _loadFormData(hike);
                    setState(() => _isEditing = true);
                  },
                );
              },
            ).value ?? const SizedBox.shrink()
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
            ),
        ],
      ),
      body: hikeDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (hike) {
          if (hike == null) {
            return const Center(child: Text('Data pendakian tidak ditemukan.'));
          }

          if (_isEditing) {
            return _buildEditMode(hike);
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
                      if (hike.durationMinutes != null) ...[
                        const Divider(height: 16),
                        _buildInfoRow(
                          Icons.timer_outlined,
                          'Durasi',
                          '${hike.durationMinutes} menit',
                        ),
                      ],
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
                      if (hike.partners != null && hike.partners!.isNotEmpty) ...[
                        const Divider(height: 16),
                        _buildInfoRow(Icons.people_outline, 'Partner', hike.partners!),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- 4. MODIFIKASI: _buildRouteMap sekarang butuh 'ref' ---
              Text('Peta Rute 🗺️', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              _buildRouteMap(context, ref, widget.localHikeId), // <-- 'ref' dioper
              // --- AKHIR MODIFIKASI ---
              
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
              
              // --- 5. MODIFIKASI: _buildPhotoGallery sekarang butuh 'ref' ---
              Text('Galeri Jejak 📸', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              _buildPhotoGallery(context, ref, widget.localHikeId), // <-- 'ref' dioper
              // --- AKHIR MODIFIKASI ---
              
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

  // ... (_buildEditMode dan _buildInfoRow tetap sama) ...
  Widget _buildEditMode(Hike hike) {
    // ... (Tidak ada perubahan di sini)
    final dateText =
        '${_selectedDate?.day ?? hike.hikeDate.day}/${_selectedDate?.month ?? hike.hikeDate.month}/${_selectedDate?.year ?? hike.hikeDate.year}';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField( controller: _mountainNameController, decoration: const InputDecoration( labelText: 'Nama Gunung/Lokasi', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on), ), enabled: !_isSaving, ),
          const SizedBox(height: 16),
          InkWell( onTap: _isSaving ? null : _pickDate, child: Container( padding: const EdgeInsets.all(16), decoration: BoxDecoration( border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8), ), child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text(dateText), Icon(Icons.calendar_month, color: Colors.grey.shade600), ], ), ), ),
          const SizedBox(height: 16),
          Row( children: [ Expanded( child: TextField( controller: _durationController, decoration: const InputDecoration( labelText: 'Durasi (menit)', border: OutlineInputBorder(), ), keyboardType: TextInputType.number, enabled: !_isSaving, ), ), const SizedBox(width: 12), Expanded( child: TextField( controller: _distanceController, decoration: const InputDecoration( labelText: 'Jarak (km)', border: OutlineInputBorder(), ), keyboardType: TextInputType.number, enabled: !_isSaving, ), ), ], ),
          const SizedBox(height: 16),
          TextField( controller: _elevationController, decoration: const InputDecoration( labelText: 'Tanjakan (meter)', border: OutlineInputBorder(), ), keyboardType: TextInputType.number, enabled: !_isSaving, ),
          const SizedBox(height: 16),
          TextField( controller: _partnersController, decoration: const InputDecoration( labelText: 'Partner (Opsional)', border: OutlineInputBorder(), ), enabled: !_isSaving, ),
          const SizedBox(height: 16),
          TextField( controller: _notesController, decoration: const InputDecoration( labelText: 'Catatan (Opsional)', border: OutlineInputBorder(), ), maxLines: 3, enabled: !_isSaving, ),
          const SizedBox(height: 32),
          SizedBox( width: double.infinity, child: FilledButton.icon( icon: _isSaving ? const SizedBox( width: 20, height: 20, child: CircularProgressIndicator( strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white), ), ) : const Icon(Icons.save), label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Perubahan'), onPressed: _isSaving ? null : () => _saveChanges(hike), ), ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    // ... (Tidak ada perubahan di sini)
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


  // --- 6. TAMBAHKAN FUNGSI HELPER BARU INI (Salin dari MapPage) ---
  /// Helper untuk mendapatkan ikon berdasarkan kategori waypoint
  static IconData _getIconForCategory(String? category) {
    switch (category) {
      case 'POS':
        return Icons.signpost_outlined;
      case 'SUMBER_AIR':
        return Icons.water_drop_outlined;
      case 'PUNCAK':
        return Icons.flag_outlined;
      case 'CAMP':
        return Icons.local_fire_department_outlined;
      default:
        return Icons.location_pin;
    }
  }

  // --- 7. TAMBAHKAN FUNGSI MODAL BARU INI ---
  /// Menampilkan Bottom Sheet untuk detail waypoint
  void _showWaypointDetails(BuildContext context, WidgetRef ref, HikeWaypoint waypoint) {
    final theme = Theme.of(context);
    final numberFormat = NumberFormat.decimalPattern('id'); // Format angka
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Izinkan sheet jadi tinggi
      builder: (ctx) {
        return Consumer( // Kita butuh Consumer baru di sini untuk 'modalRef'
          builder: (context, modalRef, child) {
            
            // Tonton provider FOTO SPESIFIK untuk waypoint ini
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
                  // --- NAMA & KATEGORI ---
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
                                waypoint.category!, // Misal: "POS"
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

                  // --- FOTO (JIKA ADA) ---
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

                  // --- STATISTIK ---
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
                  const SizedBox(height: 20), // Spasi aman
                ],
              ),
            );
          }
        );
      },
    );
  }
  // --- AKHIR FUNGSI MODAL ---


  // --- 8. UPGRADE FUNGSI _buildRouteMap ---
  Widget _buildRouteMap(BuildContext context, WidgetRef ref, int hikeId) {
    final routePointsAsync = ref.watch(routePointsProvider(hikeId));
    final waypointsAsync = ref.watch(hikeWaypointsProvider(hikeId));

    return routePointsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(
        child: Text('Gagal memuat rute: $e', style: const TextStyle(color: Colors.red)),
      ),
      data: (points) {
        if (points.isEmpty) {
          // ... (Tampilan 'Rute tidak terekam' Anda sudah benar)
          return Container( height: 200, alignment: Alignment.center, decoration: BoxDecoration( color: Colors.grey[100], borderRadius: BorderRadius.circular(12.0), border: Border.all(color: Colors.grey[300]!), ), child: Text( 'Rute GPS tidak terekam untuk pendakian ini.', style: TextStyle(color: Colors.grey[600]), ), );
        }

        final List<LatLng> polylinePoints = points
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();
        final bounds = LatLngBounds.fromPoints(polylinePoints);

        // --- PERUBAHAN: Modifikasi Marker ---
        final List<Marker> markers = waypointsAsync.maybeWhen(
          data: (waypoints) => waypoints
              .map(
                (wp) => Marker(
                  width: 40.0,
                  height: 40.0,
                  point: LatLng(wp.latitude, wp.longitude),
                  child: IconButton(
                    // Gunakan ikon kategori baru
                    icon: Icon(_getIconForCategory(wp.category),
                        color: Colors.purple.shade700, size: 35),
                    tooltip: wp.name,
                    // Panggil modal baru, bukan SnackBar
                    onPressed: () {
                      _showWaypointDetails(context, ref, wp);
                    },
                  ),
                ),
              )
              .toList(),
          orElse: () => [],
        );
        // --- AKHIR PERUBAHAN ---

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
                MarkerLayer(markers: markers), // Tampilkan marker yang sudah di-upgrade
              ],
            ),
          ),
        );
      },
    );
  }
  // --- AKHIR UPGRADE _buildRouteMap ---


  // --- 9. UPGRADE FUNGSI _buildPhotoGallery ---
  Widget _buildPhotoGallery(BuildContext context, WidgetRef ref, int hikeId) {
    final photosAsync = ref.watch(hikePhotosProvider(hikeId));
    return photosAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, s) => Center(
        child: Text('Gagal memuat foto: $e', style: const TextStyle(color: Colors.red)),
      ),
      data: (photos) {
        
        // --- PERUBAHAN: Filter foto waypoint ---
        // Hanya ambil foto "Umum" (yang waypointId-nya null)
        final generalPhotos = photos.where((p) => p.waypointId == null).toList();
        // --- AKHIR PERUBAHAN ---

        if (generalPhotos.isEmpty) { // <-- Gunakan list baru
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
          itemCount: generalPhotos.length, // <-- Gunakan panjang list baru
          itemBuilder: (context, index) {
            final photo = generalPhotos[index]; // <-- Gunakan list baru
            final heroTag = 'hike-photo-${photo.id}';

            // Sisa kode (GestureDetector, Hero, Image.network) sudah benar
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
  // --- AKHIR UPGRADE _buildPhotoGallery ---
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